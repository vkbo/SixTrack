#ifdef HDF5

! ================================================================================================ !
!  Special HDF5 Module for Writing Linear Optics Parameters
!  V.K. Berglyd Olsen, BE-ABP-HSS
!  Last Modified: 2018-05-09
! ================================================================================================ !
module hdf5_linopt
  
  use hdf5_output
  use mod_alloc
  use mod_commons
  
  implicit none
  
  integer,                       private, save :: h5lin_nElem(2)
  integer,          allocatable, private, save :: h5lin_iData(:)
  character(len=:), allocatable, private, save :: h5lin_cData(:)
  real(kind=fPrec), allocatable, private, save :: h5lin_rData(:,:)
  
contains

subroutine h5lin_init

  h5lin_nElem(1) = 0
  h5lin_nElem(2) = 1000

  call alloc(h5lin_iData,               h5lin_nElem(2), 0,                            "h5lin_iData")
  call alloc(h5lin_cData, max_name_len, h5lin_nElem(2), repeat(char(0),max_name_len), "h5lin_cData")
  call alloc(h5lin_rData, 17,           h5lin_nElem(2), 0.0_fPrec,                    "h5lin_rData")

end subroutine h5lin_init

subroutine h5lin_writeLine(lineNo, elemType, arrData)
  
  integer,          intent(in) :: lineNo
  character(len=*), intent(in) :: elemType
  real(kind=fPrec), intent(in) :: arrData(17)
  
  h5lin_nElem(1) = h5lin_nElem(1) + 1
  
  if(h5lin_nElem(1) > h5lin_nElem(2)) then
    h5lin_nElem(2) = h5lin_nElem(2) + 1000
    call resize(h5lin_iData,               h5lin_nElem(2), 0,                            "h5lin_iData")
    call resize(h5lin_cData, max_name_len, h5lin_nElem(2), repeat(char(0),max_name_len), "h5lin_cData")
    call resize(h5lin_rData, 17,           h5lin_nElem(2), 0.0_fPrec,                    "h5lin_rData")
  end if
  
  h5lin_iData(h5lin_nElem(1))   = lineNo
  h5lin_cData(h5lin_nElem(1))   = elemType
  h5lin_rData(:,h5lin_nElem(1)) = arrData
  
end subroutine h5lin_writeLine

subroutine h5lin_saveData
  
  type(h5_dataField), allocatable :: setFields(:)
  integer optFmt, optSet, rIdx
  
  allocate(setFields(19))
  
  setFields(1)  = h5_dataField(name="NR",     type=h5_typeInt)
  setFields(2)  = h5_dataField(name="TYP",    type=h5_typeChar, size=max_name_len)
  setFields(3)  = h5_dataField(name="LTOT",   type=h5_typeReal)
  setFields(4)  = h5_dataField(name="PHIX",   type=h5_typeReal)
  setFields(5)  = h5_dataField(name="BETAX",  type=h5_typeReal)
  setFields(6)  = h5_dataField(name="ALPHAX", type=h5_typeReal)
  setFields(7)  = h5_dataField(name="GAMMAX", type=h5_typeReal)
  setFields(8)  = h5_dataField(name="DISX",   type=h5_typeReal)
  setFields(9)  = h5_dataField(name="DISXP",  type=h5_typeReal)
  setFields(10) = h5_dataField(name="CLOX",   type=h5_typeReal)
  setFields(11) = h5_dataField(name="CLOXP",  type=h5_typeReal)
  setFields(12) = h5_dataField(name="PHIY",   type=h5_typeReal)
  setFields(13) = h5_dataField(name="BETAY",  type=h5_typeReal)
  setFields(14) = h5_dataField(name="ALPHAY", type=h5_typeReal)
  setFields(15) = h5_dataField(name="GAMMAY", type=h5_typeReal)
  setFields(16) = h5_dataField(name="DISY",   type=h5_typeReal)
  setFields(17) = h5_dataField(name="DISYP",  type=h5_typeReal)
  setFields(18) = h5_dataField(name="CLOY",   type=h5_typeReal)
  setFields(19) = h5_dataField(name="CLOYP",  type=h5_typeReal)
  
  call h5_createFormat("linearOptics", setFields, optFmt)
  call h5_createDataSet("linopt", h5_rootID, optFmt, optSet, 2000)
  
  call h5_prepareWrite(optSet, h5lin_nElem(1))
  call h5_writeData(optSet, 1, h5lin_nElem(1), h5lin_iData)
  call h5_writeData(optSet, 2, h5lin_nElem(1), h5lin_cData)
  do rIdx=1,17
    call h5_writeData(optSet, rIdx+2, h5lin_nElem(1), h5lin_rData(rIdx,:))
  end do
  call h5_finaliseWrite(optSet)
  
  deallocate(setFields)
  
  call dealloc(h5lin_iData,               "h5lin_iData")
  call dealloc(h5lin_cData, max_name_len, "h5lin_cData")
  call dealloc(h5lin_rData,               "h5lin_rData")
  
end subroutine h5lin_saveData

end module hdf5_linopt

!>
!! @brief module that contains the code necessary for hdf5 support
!!
!<
!       MODULE SIXTRACKHDF5
!       use floatPrecision
!       USE HDF5
      
!       use crcoall
!       use crcoall
!       IMPLICIT NONE

!         CHARACTER(LEN=20), PARAMETER :: HFNAME = "tracks2.h5"
!         INTEGER(HID_T) :: hfile_id
!         INTEGER(HID_T) :: h5set_id       ! Dataset identifier
!         INTEGER(HID_T) :: h5space_id,memspace     ! Dataspace identifier
!         INTEGER(HID_T) :: crp_list        ! dataset creatation property identifier 
!         CHARACTER(LEN=6), PARAMETER :: h5setname = "tracks"     ! Dataset name
!         INTEGER     ::   h5error
!         INTEGER, PARAMETER :: incr = 1024
!         INTEGER(HSIZE_T), DIMENSION(2) :: h5dims,maxdims,data_dims,     &
!      &                                    offset
!         INTEGER     ::   h5rank = 2                        ! Dataset rank
!         REAL, DIMENSION(9,incr) :: data_in2
!       CONTAINS
      
!       SUBROUTINE WRITETOFILE
!           use floatPrecision
!           CALL h5dextend_f(h5set_id, h5dims, h5error)
!           CALL h5dget_space_f(h5set_id, h5space_id, h5error)
          
!           !
!           ! Get updated dataspace
!           !
!           data_dims(1)=9 ! to be sure..
!           data_dims(2)=mod(h5dims(2)-1,incr)+1
!           offset(1)=0
!           offset(2)=h5dims(2)-data_dims(2)
!           !
!           ! Select hyperslab in the dataset.
!           !
!           CALL h5sselect_hyperslab_f(h5space_id, H5S_SELECT_SET_F,      &
!      &                               offset, data_dims , h5error)
!           CALL h5screate_simple_f(h5rank, data_dims, memspace, h5error) 
! #ifdef DEBUG
!       write (lout,*) "DBG HDFw",h5dims,"off",offset,"ddims",data_dims
! #endif
!           CALL H5dwrite_f(h5set_id, H5T_NATIVE_REAL, data_in2,          &
!             data_dims, h5error,file_space_id = h5space_id, mem_space_id &
!      &       = memspace)
!       END SUBROUTINE WRITETOFILE
!       END MODULE SIXTRACKHDF5
     
!       !>
!       !! @todo attribute (header) not yet working...
!       !< 
!       SUBROUTINE INITHDF5
!         use floatPrecision
!         USE SIXTRACKHDF5

!         CHARACTER(LEN=9), PARAMETER :: aname = "header"   ! Attribute name

!         INTEGER(HID_T) :: attr_id       ! Attribute identifier 
!         INTEGER(HID_T) :: aspace_id     ! Attribute Dataspace identifier 
!         INTEGER(HID_T) :: atype_id      ! Attribute Dataspace identifier 
!         INTEGER(HSIZE_T) :: adims = 1   ! Attribute dimension
!         INTEGER     ::   arank = 1      ! Attribure rank
!         INTEGER(SIZE_T) :: attrlen      ! Length of the attribute string

!         CHARACTER(80) ::  attr_data      ! Attribute data
!         attr_data = "1=pid 2=turn 3=s 4=x 5=xp 6=y 7=yp 8=DE/E 9=type"
!         attrlen = 80
!         h5dims=(/9,0/)

!           !Initialize FORTRAN predifined datatypes
!           CALL h5open_f(h5error) 

!           CALL h5fcreate_f(HFNAME, H5F_ACC_TRUNC_F, hfile_id, h5error)
          
!           !Create the data space with unlimited length.
!           maxdims = (/INT(9,HSIZE_T), H5S_UNLIMITED_F/)
!           CALL h5screate_simple_f(h5rank, h5dims, h5space_id,           &
!      &      h5error, maxdims)
!           !Modify dataset creation properties, i.e. enable chunking
!           CALL h5pcreate_f(H5P_DATASET_CREATE_F, crp_list, h5error)
!           CALL h5pset_deflate_f (crp_list, 4, h5error)
          
!           data_dims=(/9,incr/)
!           CALL h5pset_chunk_f(crp_list, h5rank, data_dims, h5error)
          
!           !Create a dataset with 9Xunlimited dimensions using cparms creation properties .
!           CALL h5dcreate_f(hfile_id, h5setname, H5T_NATIVE_REAL,        &
!      &                     h5space_id, h5set_id, h5error, crp_list )

!           ! Create datatype for the attribute.
!           CALL h5tcopy_f(H5T_NATIVE_CHARACTER, atype_id, h5error)
!           CALL h5tset_size_f(atype_id, attrlen, h5error)

!           !Create a dataspace for the attribute
!           CALL h5screate_f(H5S_SCALAR_F,aspace_id,h5error)

!           ! Create dataset attribute.
!           CALL h5acreate_f(h5set_id, aname, atype_id, aspace_id,        &
!      &                     attr_id, h5error)
          
!           ! Write the attribute data.
!           data_dims(1) = 1
!           CALL h5awrite_f                                               &
!      &    (attr_id, atype_id, attr_data, data_dims, h5error)
!           data_dims(1) = 9
!           ! Close the attribute. 
!           CALL h5aclose_f(attr_id, h5error)
    
!       END SUBROUTINE INITHDF5

!       SUBROUTINE APPENDREADING(pid,turn,s,x,xp,y,yp,dee,typ)
!        use floatPrecision
!        USE SIXTRACKHDF5
!        INTEGER turn,pid,typ
!        real(kind=fPrec) x,xp,y,yp,dee,s

! #ifdef DEBUG
!       write (lout,*) "DBG HDF app: using position mod(h5dims(2),incr)", &
!       & mod(h5dims(2),incr)
! #endif
!        data_in2(1,mod(h5dims(2),incr) + 1)=pid
!        data_in2(2,mod(h5dims(2),incr) + 1)=turn
!        data_in2(3,mod(h5dims(2),incr) + 1)=s
!        data_in2(4,mod(h5dims(2),incr) + 1)=x
!        data_in2(5,mod(h5dims(2),incr) + 1)=xp
!        data_in2(6,mod(h5dims(2),incr) + 1)=y
!        data_in2(7,mod(h5dims(2),incr) + 1)=yp
!        data_in2(8,mod(h5dims(2),incr) + 1)=dee
!        data_in2(9,mod(h5dims(2),incr) + 1)=typ

!        h5dims(2)=h5dims(2)+1
! #ifdef DEBUG
!        write (lout,*) "DBG HDF app: h5dims(2) now,", h5dims(2)
! #endif

! #ifdef DEBUG
! !rkwee
!        write (lout,*) "DBG HDF app: data_in2[-1]", pid, turn, &
!        & s, x, xp, y, yp, dee, typ
! #endif
!           !
!           !Extend the dataset. Dataset becomes 10 x 3.
!           !
!           if (mod(h5dims(2),incr).eq.0) then
!               CALL WRITETOFILE()
!           endif
!       END SUBROUTINE APPENDREADING
      
!       SUBROUTINE CLOSEHDF5
!        use floatPrecision
!        USE SIXTRACKHDF5
        
!           if (mod(h5dims(2),incr).ne.0) then
!               CALL WRITETOFILE()
!           endif

!        !
!        ! End access to the dataset and release resources used by it.
!        !
!        CALL h5dclose_f(h5set_id, h5error)
  
!        !
!        ! Terminate access to the data space.
!        !
!        CALL h5sclose_f(h5space_id, h5error)
     
!        !
!        ! Close the file.
!        !
!        CALL h5fclose_f(hfile_id, h5error)
  
!        !
!        ! Close FORTRAN interface.
!        !
!        CALL h5close_f(h5error)
!       END SUBROUTINE CLOSEHDF5
      
#endif

