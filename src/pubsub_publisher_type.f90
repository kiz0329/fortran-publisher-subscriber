module pubsub_publisher_type
    !! Publisher type for the publisher-broker-subscriber pattern.
    !!
    !! A publisher sends messages to a broker, which routes them
    !! to the appropriate subscribers. Implementation is separated
    !! into a submodule.
    use pubsub_broker_type, only: broker_type
    implicit none
    private

    public :: publisher_type

    type :: publisher_type
        !! Type implementing a publisher in the publisher-broker-subscriber pattern.
        private
        character(len=:), allocatable :: name
        character(len=:), allocatable :: topic
        type(broker_type), pointer :: broker => null()
    contains
        procedure :: publish
        procedure :: disconnect
        procedure :: get_name
        procedure :: get_topic
        final :: finalize_publisher
    end type publisher_type

    interface publisher_type
        !! Constructor for publisher_type.
        module function new_publisher(name, topic, broker) result(pub)
            character(len=*), intent(in) :: name
            character(len=*), intent(in) :: topic
            type(broker_type), target, intent(inout) :: broker
            type(publisher_type) :: pub
        end function new_publisher
    end interface

    interface

        module subroutine publish(self, message)
            !! Publish a message through the broker.
            class(publisher_type), intent(inout) :: self
            character(len=*), intent(in) :: message
        end subroutine publish

        module subroutine disconnect(self)
            !! Detach this publisher from its broker.
            class(publisher_type), intent(inout) :: self
        end subroutine disconnect

        pure module function get_name(self) result(name)
            !! Returns the name of the publisher.
            class(publisher_type), intent(in) :: self
            character(len=:), allocatable :: name
        end function get_name

        pure module function get_topic(self) result(topic)
            !! Returns the topic of the publisher.
            class(publisher_type), intent(in) :: self
            character(len=:), allocatable :: topic
        end function get_topic

        module subroutine finalize_publisher(self)
            !! Finalizer that detaches the broker pointer.
            type(publisher_type), intent(inout) :: self
        end subroutine finalize_publisher

    end interface

end module pubsub_publisher_type
