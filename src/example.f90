module example
  implicit none
  private

  public :: say_hello
contains
  subroutine say_hello
    print *, "Hello, example!"
  end subroutine say_hello
end module example
