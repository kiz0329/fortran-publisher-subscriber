module pubsub_publisher_type
   implicit none
   private

   type, abstract :: publisher_type
   contains
      procedure(publish_interface), deferred :: publish
   end type publisher_type

contains
end module pubsub_publisher_type
