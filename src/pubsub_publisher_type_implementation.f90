submodule (pubsub_publisher_type) pubsub_publisher_type_implementation
    !! Implementation of the publisher_type procedures.
    implicit none

contains

    module function new_publisher(name, broker) result(pub)
        character(len=*), intent(in) :: name
        type(broker_type), target, intent(inout) :: broker
        type(publisher_type) :: pub

        pub%name = name
        pub%broker => broker
    end function new_publisher


    module subroutine publish(self, topic, message)
        class(publisher_type), intent(inout) :: self
        character(len=*), intent(in) :: topic
        character(len=*), intent(in) :: message

        if (associated(self%broker)) then
            call self%broker%publish(topic, self%name, message)
        end if
    end subroutine publish


    pure module function get_name(self) result(name)
        class(publisher_type), intent(in) :: self
        character(len=:), allocatable :: name

        name = self%name
    end function get_name

    module subroutine finalize_publisher(self)
        type(publisher_type), intent(inout) :: self

        nullify(self%broker)
    end subroutine finalize_publisher

end submodule pubsub_publisher_type_implementation
