# fortran-publisher-subscriber

A lightweight **Publisher-Subscriber (Pub/Sub) pattern** implementation in modern Fortran, built with [fpm](https://fpm.fortran-lang.org/).

## Overview

This library provides two core types for event-driven communication:

| Type | Description |
|---|---|
| `publisher_type` | Maintains a list of subscribers and broadcasts messages to them. |
| `subscriber_type` | Abstract base type. Extend it and implement the `update` callback to react to notifications. |

Key features:

- Simple, clean API: `subscribe`, `unsubscribe`, `notify`
- Duplicate subscription prevention
- Dynamic subscriber list with automatic capacity growth
- Fully decoupled publishers and subscribers

## Requirements

- A Fortran compiler supporting Fortran 2008+ submodules (e.g., GFortran 9+, Intel ifx)
- [fpm](https://fpm.fortran-lang.org/) (Fortran Package Manager)

## Installation

### As an fpm dependency

Add to your project's `fpm.toml`:

```toml
[dependencies]
fortran-publisher-subscriber = { git = "https://github.com/kiz0329/fortran-publisher-subscriber.git" }
```

### Build from source

```bash
git clone https://github.com/kiz0329/fortran-publisher-subscriber.git
cd fortran-publisher-subscriber
fpm build
```

## Usage

### 1. Import the module

The library exposes a single entry-point module `pubsub` that re-exports both public types:

```fortran
use pubsub, only: publisher_type, subscriber_type
```

### 2. Define a concrete subscriber

Extend the abstract `subscriber_type` and implement the deferred `update` subroutine. The `update` callback receives the publisher's name and a message string:

```fortran
module my_subscriber_m
    use pubsub, only: subscriber_type
    implicit none

    type, extends(subscriber_type) :: my_subscriber
        character(len=64) :: name = ''
    contains
        procedure :: update => my_update
    end type my_subscriber

contains

    subroutine my_update(self, publisher_name, message)
        class(my_subscriber), intent(inout) :: self
        character(len=*), intent(in) :: publisher_name
        character(len=*), intent(in) :: message

        print '(a,a,a,a,a,a)', "[", trim(self%name), &
            "] Received from '", publisher_name, "': ", message
    end subroutine my_update

end module my_subscriber_m
```

### 3. Create a publisher and manage subscriptions

```fortran
program main
    use pubsub, only: publisher_type
    use my_subscriber_m, only: my_subscriber
    implicit none

    type(publisher_type) :: news
    type(my_subscriber), target :: sub1, sub2

    ! Initialize subscribers
    sub1%name = "Sub-1"
    sub2%name = "Sub-2"

    ! Create a publisher with a name
    news = publisher_type("News Agency")

    ! Subscribe
    call news%subscribe(sub1)
    call news%subscribe(sub2)
    print '(a,i0)', "Subscribers: ", news%get_num_subscribers()
    ! Output: Subscribers: 2

    ! Notify all subscribers
    call news%notify("Breaking news!")
    ! Output:
    !   [Sub-1] Received from 'News Agency': Breaking news!
    !   [Sub-2] Received from 'News Agency': Breaking news!

    ! Unsubscribe
    call news%unsubscribe(sub1)
    print '(a,i0)', "Subscribers: ", news%get_num_subscribers()
    ! Output: Subscribers: 1

    ! Only remaining subscribers are notified
    call news%notify("More news!")
    ! Output:
    !   [Sub-2] Received from 'News Agency': More news!

end program main
```

> **Note:** Subscriber variables passed to `subscribe` and `unsubscribe` must have the `target` attribute, since the publisher stores pointers to them internally.

## API Reference

### `publisher_type`

#### Constructor

```fortran
type(publisher_type) :: pub
pub = publisher_type(name)
```

| Argument | Type | Intent | Description |
|---|---|---|---|
| `name` | `character(len=*)` | `in` | Name identifying this publisher. |

#### Methods

| Method | Signature | Description |
|---|---|---|
| `subscribe` | `call pub%subscribe(sub)` | Add a subscriber. Duplicates are silently ignored. |
| `unsubscribe` | `call pub%unsubscribe(sub)` | Remove a subscriber. No-op if not subscribed. |
| `notify` | `call pub%notify(message)` | Send `message` to all current subscribers via their `update` callback. |
| `get_num_subscribers` | `n = pub%get_num_subscribers()` | Returns the current number of subscribers (pure). |
| `get_name` | `name = pub%get_name()` | Returns the publisher's name (pure). |

### `subscriber_type` (abstract)

Extend this type and implement the deferred procedure:

```fortran
subroutine update(self, publisher_name, message)
    class(my_subscriber), intent(inout) :: self
    character(len=*), intent(in) :: publisher_name  ! name of the notifying publisher
    character(len=*), intent(in) :: message          ! the notification payload
end subroutine
```

## Running the Example

```bash
fpm run --example example_pubsub
```

## Running Tests

```bash
fpm test
```

## License

MIT License. See [LICENSE](LICENSE) for details.