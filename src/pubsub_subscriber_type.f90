module pubsub_subscriber_type
    !! Abstract subscriber type for the publisher-subscriber pattern.
    !!
    !! Concrete subscribers must extend this type and implement the
    !! deferred `update` procedure.
    implicit none
    private

    public :: subscriber_type

    type, abstract :: subscriber_type
        !! Abstract base type for subscribers.
    contains
        procedure(update_interface), deferred :: update
    end type subscriber_type

    abstract interface
        subroutine update_interface(self, publisher_name, message)
            !! Callback invoked when a subscribed publisher sends a notification.
            import :: subscriber_type
            class(subscriber_type), intent(inout) :: self
            character(len=*), intent(in) :: publisher_name
            character(len=*), intent(in) :: message
        end subroutine update_interface
    end interface

end module pubsub_subscriber_type
