character(len=8) version  ! Keep data type in sync with 'cr_version'
character(len=10) moddate ! Keep data type in sync with 'cr_moddate'
data version /'5.0.1'/
data moddate /'21.08.2018'/

!CMake will replace this with the current git sha hash at generation time
character(len=40), parameter :: git_revision = SIXTRACK_GIT_REVISION
