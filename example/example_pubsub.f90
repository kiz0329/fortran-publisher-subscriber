module example_pubsub_m
    use pubsub, only: subscriber_type
    implicit none

    type, extends(subscriber_type) :: logger_subscriber
        character(len=64) :: name = ''
    contains
        procedure :: update => logger_update
    end type logger_subscriber

contains

    subroutine logger_update(self, publisher_name, message)
        class(logger_subscriber), intent(inout) :: self
        character(len=*), intent(in) :: publisher_name
        character(len=*), intent(in) :: message

        print '(a,a,a,a,a,a)', "[", trim(self%name), &
            "] Received from '", publisher_name, "': ", message
    end subroutine logger_update

end module example_pubsub_m


program example_pubsub
    use pubsub, only: broker_type, publisher_type
    use example_pubsub_m, only: logger_subscriber
    implicit none

    type(broker_type), target :: broker
    type(publisher_type) :: news
    type(logger_subscriber), target :: logger1, logger2

    ! Set up subscribers
    logger1%name = "Logger-1"
    logger2%name = "Logger-2"

    ! Create a broker
    broker = broker_type()

    ! Create a publisher linked to the broker
    news = publisher_type("News Agency", "news", broker)

    ! Subscribe both loggers to the "news" topic via the broker
    call broker%subscribe("news", logger1)
    call broker%subscribe("news", logger2)
    print '(a,i0)', "Subscribers: ", broker%get_num_subscribers("news")
    ! Subscribers: 2

    ! Publish a message (routed through the broker)
    call news%publish("Breaking news!")
    ! [Logger-1] Received from 'News Agency': Breaking news!
    ! [Logger-2] Received from 'News Agency': Breaking news!

    ! Unsubscribe logger1 via the broker
    call broker%unsubscribe("news", logger1)
    print '(a,i0)', "Subscribers after unsubscribe: ", broker%get_num_subscribers("news")
    ! Subscribers after unsubscribe: 1

    ! Publish another message
    call news%publish("More news!")
    ! [Logger-2] Received from 'News Agency': More news!

end program example_pubsub
