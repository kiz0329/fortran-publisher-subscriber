module pubsub
    !! Publisher-subscriber pattern implementation.
    !!
    !! This module re-exports the public types from the pubsub library,
    !! providing a single entry point for users.
    use pubsub_subscriber_type, only: subscriber_type
    use pubsub_publisher_type, only: publisher_type
    implicit none
    private

    public :: subscriber_type, publisher_type

end module pubsub
