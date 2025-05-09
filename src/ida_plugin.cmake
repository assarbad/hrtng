function (ADD_IDA_PLUGIN	target_name )

INCLUDE_DIRECTORIES(${IDASDK_DIR}/include)

ADD_LIBRARY(${target_name} SHARED	${ARGN} )
SET_TARGET_PROPERTIES(${target_name} PROPERTIES PREFIX "" )

IF(NOT ${UNI64})
  ADD_LIBRARY(${target_name}_64 SHARED	${ARGN} )
  SET_TARGET_PROPERTIES(${target_name}_64 PROPERTIES PREFIX "" )
ENDIF()

SET(CMAKE_CXX_STANDARD 11)
SET(OPT_CXX_FLAGS "-std=c++11 -flto -fvisibility=hidden -fvisibility-inlines-hidden")
SET(IDA_COMMON_CXX_FLAGS "-D__X64__ -DUSE_DANGEROUS_FUNCTIONS")

IF (${IDASDK_VER} STREQUAL "83" OR ${IDASDK_VER} STREQUAL "84")
  SET(PRO "_pro")
ELSE ()
  SET(PRO  "")
ENDIF ()

IF(MSVC)
   SET(COMMON_FLAGS "${CMAKE_CXX_FLAGS} -D __NT__ ${IDA_COMMON_CXX_FLAGS} ")
  IF(${UNI64})
   TARGET_LINK_LIBRARIES(${target_name} ${IDASDK_DIR}/lib/x64_win_vc_64${PRO}/ida.lib)
  ELSE()
   TARGET_LINK_LIBRARIES(${target_name}    ${IDASDK_DIR}/lib/x64_win_vc_32${PRO}/ida.lib)
   TARGET_LINK_LIBRARIES(${target_name}_64 ${IDASDK_DIR}/lib/x64_win_vc_64${PRO}/ida.lib)
  ENDIF()
ELSEIF(APPLE)
   SET(COMMON_FLAGS "${CMAKE_CXX_FLAGS} -D__MAC__ ${IDA_COMMON_CXX_FLAGS}  ${OPT_CXX_FLAGS}")
  IF(${CMAKE_SYSTEM_PROCESSOR} STREQUAL "arm64")
    IF(${UNI64})
      TARGET_LINK_LIBRARIES(${target_name}    ${IDASDK_DIR}/lib/arm64_mac_clang_64${PRO}/libida.dylib -s -flto)
    ELSE()
      TARGET_LINK_LIBRARIES(${target_name}    ${IDASDK_DIR}/lib/arm64_mac_clang_32${PRO}/libida.dylib -s -flto)
      TARGET_LINK_LIBRARIES(${target_name}_64 ${IDASDK_DIR}/lib/arm64_mac_clang_64${PRO}/libida64.dylib -s -flto)
    ENDIF()
  ELSE()
    IF(${UNI64})
      TARGET_LINK_LIBRARIES(${target_name}    ${IDASDK_DIR}/lib/x64_mac_clang_64${PRO}/libida.dylib -s -flto)
    ELSE()
      TARGET_LINK_LIBRARIES(${target_name}    ${IDASDK_DIR}/lib/x64_mac_clang_32${PRO}/libida.dylib -s -flto)
      TARGET_LINK_LIBRARIES(${target_name}_64 ${IDASDK_DIR}/lib/x64_mac_clang_64${PRO}/libida64.dylib -s -flto)
    ENDIF()
  ENDIF()
ELSEIF ( ${CMAKE_SYSTEM_NAME} STREQUAL "Linux")
  SET(COMMON_FLAGS "${CMAKE_CXX_FLAGS} -D__LINUX__ ${IDA_COMMON_CXX_FLAGS} ${OPT_CXX_FLAGS}")
  SET(GCC_LINK_FLAGS "-Wl,--version-script=${IDASDK_DIR}/plugins/exports.def -Wl,--strip-debug,--discard-all,--strip-all,--discard-locals -flto=auto")
  IF(${UNI64})
    TARGET_LINK_LIBRARIES(${target_name}    ${IDASDK_DIR}/lib/x64_linux_gcc_64/libida.so ${OPT_CXX_FLAGS} ${GCC_LINK_FLAGS})
  ELSE()
    TARGET_LINK_LIBRARIES(${target_name}    ${IDASDK_DIR}/lib/x64_linux_gcc_32${PRO}/libida.so ${OPT_CXX_FLAGS} ${GCC_LINK_FLAGS})
    TARGET_LINK_LIBRARIES(${target_name}_64 ${IDASDK_DIR}/lib/x64_linux_gcc_64${PRO}/libida64.so ${OPT_CXX_FLAGS} ${GCC_LINK_FLAGS})
  ENDIF()
ENDIF ()

IF(${UNI64})
   SET_TARGET_PROPERTIES(${target_name} PROPERTIES COMPILE_FLAGS "${COMMON_FLAGS} -D__EA64__")
   SET_TARGET_PROPERTIES(${target_name} PROPERTIES OUTPUT_NAME "${target_name}" )
ELSE()
   SET_TARGET_PROPERTIES(${target_name}    PROPERTIES COMPILE_FLAGS  ${COMMON_FLAGS})
   SET_TARGET_PROPERTIES(${target_name}_64 PROPERTIES COMPILE_FLAGS "${COMMON_FLAGS} -D__EA64__")
   SET_TARGET_PROPERTIES(${target_name}    PROPERTIES OUTPUT_NAME "${target_name}" )
   SET_TARGET_PROPERTIES(${target_name}_64 PROPERTIES OUTPUT_NAME "${target_name}64" )
ENDIF()

endfunction()
