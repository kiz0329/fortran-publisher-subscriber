module pubsub_broker_type
    !! Broker type for the publisher-broker-subscriber pattern.
    !!
    !! A broker manages topic-based subscriptions and routes messages
    !! from publishers to the appropriate subscribers.
    use pubsub_subscriber_type, only: subscriber_type
    implicit none
    private

    public :: broker_type

    type :: subscriber_ptr
        !! Wrapper for a pointer to a subscriber_type object.
        private
        class(subscriber_type), pointer :: ptr => null()
    end type subscriber_ptr

    type :: topic_entry
        !! Stores subscribers for a single topic.
        private
        character(len=:), allocatable :: name
        type(subscriber_ptr), allocatable :: subscribers(:)
        integer :: num_subscribers = 0
    end type topic_entry

    type :: broker_type
        !! Central broker that manages topic-based message routing.
        private
        type(topic_entry), allocatable :: topics(:)
        integer :: num_topics = 0
    contains
        procedure :: subscribe
        procedure :: unsubscribe
        procedure :: publish
        procedure :: clear
        procedure :: get_num_subscribers
        final :: finalize_broker
    end type broker_type

    interface broker_type
        !! Constructor for broker_type.
        module function new_broker() result(broker)
            type(broker_type) :: broker
        end function new_broker
    end interface

    interface

        module subroutine subscribe(self, topic_name, sub)
            !! Subscribe a subscriber to a topic.
            class(broker_type), intent(inout) :: self
            character(len=*), intent(in) :: topic_name
            class(subscriber_type), target, intent(inout) :: sub
        end subroutine subscribe

        module subroutine unsubscribe(self, topic_name, sub)
            !! Unsubscribe a subscriber from a topic.
            class(broker_type), intent(inout) :: self
            character(len=*), intent(in) :: topic_name
            class(subscriber_type), target, intent(inout) :: sub
        end subroutine unsubscribe

        module subroutine publish(self, topic_name, publisher_name, message)
            !! Publish a message to all subscribers of a topic.
            class(broker_type), intent(inout) :: self
            character(len=*), intent(in) :: topic_name
            character(len=*), intent(in) :: publisher_name
            character(len=*), intent(in) :: message
        end subroutine publish

        module subroutine clear(self)
            !! Remove all topics and detach all subscriber pointers.
            class(broker_type), intent(inout) :: self
        end subroutine clear

        pure module function get_num_subscribers(self, topic_name) result(n)
            !! Returns the number of subscribers for a topic.
            class(broker_type), intent(in) :: self
            character(len=*), intent(in) :: topic_name
            integer :: n
        end function get_num_subscribers

        module subroutine finalize_broker(self)
            !! Finalizer that detaches all internal pointers.
            type(broker_type), intent(inout) :: self
        end subroutine finalize_broker

    end interface

end module pubsub_broker_type
