
set(INKSCAPE_LIBS "")
set(INKSCAPE_INCS "")
set(INKSCAPE_INCS_SYS "")

list(APPEND INKSCAPE_INCS ${PROJECT_SOURCE_DIR}
    ${PROJECT_SOURCE_DIR}/src

    # generated includes
    ${CMAKE_BINARY_DIR}/include
)

# ----------------------------------------------------------------------------
# Files we include
# ----------------------------------------------------------------------------

find_package(GSL REQUIRED)
list(APPEND INKSCAPE_INCS_SYS ${GSL_INCLUDE_DIRS})
list(APPEND INKSCAPE_LIBS ${GSL_LIBRARIES})
if(WIN32)
    list(APPEND INKSCAPE_LIBS "-L$ENV{DEVLIBS_PATH}/lib")  # FIXME
    list(APPEND INKSCAPE_LIBS "-lpangocairo-1.0.dll")  # FIXME
    list(APPEND INKSCAPE_LIBS "-lpangoft2-1.0.dll")  # FIXME
    list(APPEND INKSCAPE_LIBS "-lpangowin32-1.0.dll")  # FIXME
    list(APPEND INKSCAPE_LIBS "-lgthread-2.0.dll")  # FIXME
elseif(APPLE)
    if(DEFINED ENV{CMAKE_PREFIX_PATH})
	# Adding the library search path explicitly seems not required
	# if MacPorts is installed in default prefix ('/opt/local') - 
	# Cmake then can rely on the hard-coded paths in its modules.
	# Only prepend search path if $CMAKE_PREFIX_PATH is defined:
	list(APPEND INKSCAPE_LIBS "-L$ENV{CMAKE_PREFIX_PATH}/lib")  # FIXME
    endif()
    list(APPEND INKSCAPE_LIBS "-lpangocairo-1.0")  # FIXME
    list(APPEND INKSCAPE_LIBS "-lpangoft2-1.0")  # FIXME
    list(APPEND INKSCAPE_LIBS "-lfontconfig")  # FIXME
    if(${GTK+_2.0_TARGET} MATCHES "x11")
	# only link X11 if using X11 backend of GTK2
	list(APPEND INKSCAPE_LIBS "-lX11")  # FIXME
    endif()
else()
    list(APPEND INKSCAPE_LIBS "-ldl")  # FIXME
    list(APPEND INKSCAPE_LIBS "-lpangocairo-1.0")  # FIXME
    list(APPEND INKSCAPE_LIBS "-lpangoft2-1.0")  # FIXME
    list(APPEND INKSCAPE_LIBS "-lfontconfig")  # FIXME
    list(APPEND INKSCAPE_LIBS "-lX11")  # FIXME
endif()

list(APPEND INKSCAPE_LIBS "-lgslcblas")  # FIXME

if(WITH_GNOME_VFS)
    find_package(GnomeVFS2)
    if(GNOMEVFS2_FOUND)
	list(APPEND INKSCAPE_INCS_SYS ${GNOMEVFS2_INCLUDE_DIR})
	list(APPEND INKSCAPE_LIBS ${GNOMEVFS-2_LIBRARY})
    else()
	set(WITH_GNOME_VFS OFF)
    endif()
endif()

if(ENABLE_LCMS)
    find_package(LCMS2)
    if(LCMS2_FOUND)
	list(APPEND INKSCAPE_INCS_SYS ${LCMS2_INCLUDE_DIRS})
	list(APPEND INKSCAPE_LIBS ${LCMS2_LIBRARIES})
	add_definitions(${LCMS2_DEFINITIONS})
        set (HAVE_LIBLCMS2 1)
    else()
        find_package(LCMS)
        if(LCMS_FOUND)
            list(APPEND INKSCAPE_INCS_SYS ${LCMS_INCLUDE_DIRS})
            list(APPEND INKSCAPE_LIBS ${LCMS_LIBRARIES})
            add_definitions(${LCMS_DEFINITIONS})
            set (HAVE_LIBLCMS1 1)
        else()
            set(ENABLE_LCMS OFF)
        endif()
    endif()
endif()

find_package(Iconv REQUIRED)
list(APPEND INKSCAPE_INCS_SYS ${ICONV_INCLUDE_DIRS})
list(APPEND INKSCAPE_LIBS ${ICONV_LIBRARIES})
add_definitions(${ICONV_DEFINITIONS})

find_package(Intl REQUIRED)
list(APPEND INKSCAPE_INCS_SYS ${Intl_INCLUDE_DIRS})
list(APPEND INKSCAPE_LIBS ${Intl_LIBRARIES})
add_definitions(${Intl_DEFINITIONS})

find_package(BoehmGC REQUIRED)
list(APPEND INKSCAPE_INCS_SYS ${BOEHMGC_INCLUDE_DIRS})
list(APPEND INKSCAPE_LIBS ${BOEHMGC_LIBRARIES})
add_definitions(${BOEHMGC_DEFINITIONS})

if(ENABLE_POPPLER)
    find_package(PopplerCairo)
    if(POPPLER_FOUND)
	set(HAVE_POPPLER ON)
	if(ENABLE_POPPLER_CAIRO)
	    if(POPPLER_CAIRO_FOUND AND POPPLER_GLIB_FOUND)
		set(HAVE_POPPLER_CAIRO ON)	  
	    endif()
	    if(POPPLER_GLIB_FOUND AND CAIRO_SVG_FOUND)
		set(HAVE_POPPLER_GLIB ON)
	    endif()
	endif()
	if(POPPLER_VERSION VERSION_GREATER "0.26.0" OR
		POPPLER_VERSION VERSION_EQUAL   "0.26.0")
	    set(POPPLER_EVEN_NEWER_COLOR_SPACE_API ON)
	endif()
	if(POPPLER_VERSION VERSION_GREATER "0.29.0" OR
		POPPLER_VERSION VERSION_EQUAL   "0.29.0")
	    set(POPPLER_EVEN_NEWER_NEW_COLOR_SPACE_API ON)
	endif()
    else()
	set(ENABLE_POPPLER_CAIRO OFF)
    endif()
else()
    set(HAVE_POPPLER OFF)
    set(ENABLE_POPPLER_CAIRO OFF)
endif()

list(APPEND INKSCAPE_INCS_SYS ${POPPLER_INCLUDE_DIRS})
list(APPEND INKSCAPE_LIBS     ${POPPLER_LIBRARIES})
add_definitions(${POPPLER_DEFINITIONS})

if(WITH_LIBWPG)
    find_package(LibWPG)
    if(LIBWPG_FOUND)
	set(WITH_LIBWPG01 ${LIBWPG-0.1_FOUND})
	set(WITH_LIBWPG02 ${LIBWPG-0.2_FOUND})
	set(WITH_LIBWPG03 ${LIBWPG-0.3_FOUND})
	list(APPEND INKSCAPE_INCS_SYS ${LIBWPG_INCLUDE_DIRS})
	list(APPEND INKSCAPE_LIBS     ${LIBWPG_LIBRARIES})
	add_definitions(${LIBWPG_DEFINITIONS})
    else()
	set(WITH_LIBWPG OFF)
    endif()
endif()

if(WITH_LIBVISIO)
    find_package(LibVisio)
    if(LIBVISIO_FOUND)
	set(WITH_LIBVISIO00 ${LIBVISIO-0.0_FOUND})
	set(WITH_LIBVISIO01 ${LIBVISIO-0.1_FOUND})
	list(APPEND INKSCAPE_INCS_SYS ${LIBVISIO_INCLUDE_DIRS})
	list(APPEND INKSCAPE_LIBS     ${LIBVISIO_LIBRARIES})
	add_definitions(${LIBVISIO_DEFINITIONS})
    else()
	set(WITH_LIBVISIO OFF)
    endif()
endif()

if(WITH_LIBCDR)
    find_package(LibCDR)
    if(LIBCDR_FOUND)
	set(WITH_LIBCDR00 ${LIBCDR-0.0_FOUND})
	set(WITH_LIBCDR01 ${LIBCDR-0.1_FOUND})
	list(APPEND INKSCAPE_INCS_SYS ${LIBCDR_INCLUDE_DIRS})
	list(APPEND INKSCAPE_LIBS     ${LIBCDR_LIBRARIES})
	add_definitions(${LIBCDR_DEFINITIONS})
    else()
	set(WITH_LIBCDR OFF)
    endif()
endif()

FIND_PACKAGE(JPEG)
IF(JPEG_FOUND)
    list(APPEND INKSCAPE_INCS_SYS ${JPEG_INCLUDE_DIR})
    list(APPEND INKSCAPE_LIBS ${JPEG_LIBRARIES})
    set(HAVE_JPEG ON)
ENDIF()

find_package(PNG REQUIRED)
list(APPEND INKSCAPE_INCS_SYS ${PNG_PNG_INCLUDE_DIR})
list(APPEND INKSCAPE_LIBS ${PNG_LIBRARY})

find_package(Popt REQUIRED)
list(APPEND INKSCAPE_INCS_SYS ${POPT_INCLUDE_DIR})
list(APPEND INKSCAPE_LIBS ${POPT_LIBRARIES})
add_definitions(${POPT_DEFINITIONS})

find_package(Potrace)
if(POTRACE_FOUND)
    list(APPEND INKSCAPE_INCS_SYS ${POTRACE_INCLUDE_DIRS})
    list(APPEND INKSCAPE_LIBS ${POTRACE_LIBRARIES})
    set(HAVE_POTRACE ON)
    add_definitions(-DHAVE_POTRACE)
else(POTRACE_FOUND)
    set(HAVE_POTRACE OFF)
    message(STATUS "Could not locate the Potrace library headers: the Trace Bitmap and Paintbucket tools will be disabled")
endif()

if(WITH_DBUS)
    find_package(DBus REQUIRED)
    if(DBUS_FOUND)
	list(APPEND INKSCAPE_INCS_SYS ${DBUS_INCLUDE_DIR})
	list(APPEND INKSCAPE_INCS_SYS ${DBUS_ARCH_INCLUDE_DIR})
	list(APPEND INKSCAPE_LIBS ${DBUS_LIBRARIES})
    else()
	set(WITH_DBUS OFF)
    endif()
endif()

if(WITH_GTEST)
    if(EXISTS "${GMOCK_DIR}" AND IS_DIRECTORY "${GMOCK_DIR}")
	
    else()
	set(WITH_GTEST off)
    endif()
endif()

# ----------------------------------------------------------------------------
# CMake's builtin
# ----------------------------------------------------------------------------

set(TRY_GTKSPELL 1)
# Include dependencies:
# use patched version until GTK2_CAIROMMCONFIG_INCLUDE_DIR is added
if("${WITH_GTK3_EXPERIMENTAL}")
    pkg_check_modules(
        GTK
        REQUIRED
        gtkmm-3.0>=3.2
        gdkmm-3.0>=3.2
        gtk+-3.0>=3.2
        gdk-3.0>=3.2
        gdl-3.0>=3.3.5
        )
    message("Using EXPERIMENTAL Gtkmm 3 build")
    set(WITH_GTKMM_3_0 1)
    message("Using external GDL")
    set(WITH_EXT_GDL 1)

    # Check whether we can use new features in Gtkmm 3.10
    # TODO: Drop this test and bump the version number in the GTK test above
    #       as soon as all supported distributions provide Gtkmm >= 3.10
    pkg_check_modules(GTKMM_3_10
	gtkmm-3.0>=3.10,
	)

    if("${GTKMM_3_10_FOUND}")
        message("Using Gtkmm 3.10 build")
        set (WITH_GTKMM_3_10 1)
    endif()

    pkg_check_modules(GDL_3_6 gdl-3.0>=3.6)

    if("${GDL_3_6_FOUND}")
        message("Using Gdl 3.6 or higher")
        set (WITH_GDL_3_6 1)
    endif()

    set(TRY_GTKSPELL )
    pkg_check_modules(GTKSPELL3 gtkspell3-3.0)

    if("${GTKSPELL3_FOUND}")
        message("Using GtkSpell3 3.0")
        set (WITH_GTKSPELL 1)
    endif()
    list(APPEND INKSCAPE_INCS_SYS
        ${GTK_INCLUDE_DIRS}
        ${GTKSPELL3_INCLUDE_DIRS}
    )

    list(APPEND INKSCAPE_LIBS
        ${GTK_LIBRARIES}
        ${GTKSPELL3_LIBRARIES}
    )
else()
    find_package(GTK2 COMPONENTS gtk gtkmm REQUIRED)
    list(APPEND INKSCAPE_INCS_SYS
        ${GTK2_GDK_INCLUDE_DIR}
        ${GTK2_GDKMM_INCLUDE_DIR}
        ${GTK2_GDK_PIXBUF_INCLUDE_DIR}
        ${GTK2_GDKCONFIG_INCLUDE_DIR}
        ${GTK2_GDKMMCONFIG_INCLUDE_DIR}
        ${GTK2_GLIB_INCLUDE_DIR}
        ${GTK2_GLIBCONFIG_INCLUDE_DIR}
        ${GTK2_GLIBMM_INCLUDE_DIR}
        ${GTK2_GLIBMMCONFIG_INCLUDE_DIR}
        ${GTK2_GTK_INCLUDE_DIR}
        ${GTK2_GTKMM_INCLUDE_DIR}
        ${GTK2_GTKMMCONFIG_INCLUDE_DIR}
        ${GTK2_ATK_INCLUDE_DIR}
        ${GTK2_ATKMM_INCLUDE_DIR}
        ${GTK2_PANGO_INCLUDE_DIR}
        ${GTK2_PANGOMM_INCLUDE_DIR}
        ${GTK2_PANGOMMCONFIG_INCLUDE_DIR}
        ${GTK2_CAIRO_INCLUDE_DIR}
        ${GTK2_CAIROMM_INCLUDE_DIR}
        ${GTK2_CAIROMMCONFIG_INCLUDE_DIR} # <-- not in cmake 2.8.4
        ${GTK2_GIOMM_INCLUDE_DIR}
        ${GTK2_GIOMMCONFIG_INCLUDE_DIR}
        ${GTK2_SIGC++_INCLUDE_DIR}
        ${GTK2_SIGC++CONFIG_INCLUDE_DIR}
	)

    list(APPEND INKSCAPE_LIBS
        ${GTK2_GDK_LIBRARY}
        ${GTK2_GDKMM_LIBRARY}
        ${GTK2_GDK_PIXBUF_LIBRARY}
        ${GTK2_GLIB_LIBRARY}
        ${GTK2_GLIBMM_LIBRARY}
        ${GTK2_GTK_LIBRARY}
        ${GTK2_GTKMM_LIBRARY}
        ${GTK2_ATK_LIBRARY}
        ${GTK2_ATKMM_LIBRARY}
        ${GTK2_PANGO_LIBRARY}
        ${GTK2_PANGOMM_LIBRARY}
        ${GTK2_CAIRO_LIBRARY}
        ${GTK2_CAIROMM_LIBRARY}
        ${GTK2_GIOMM_LIBRARY}
        ${GTK2_SIGC++_LIBRARY}
        ${GTK2_GOBJECT_LIBRARY}
	)
endif()

find_package(Freetype REQUIRED)
list(APPEND INKSCAPE_INCS_SYS ${FREETYPE_INCLUDE_DIRS})
list(APPEND INKSCAPE_LIBS ${FREETYPE_LIBRARIES})

find_package(Boost REQUIRED)
list(APPEND INKSCAPE_INCS_SYS ${Boost_INCLUDE_DIRS})
# list(APPEND INKSCAPE_LIBS ${Boost_LIBRARIES})

find_package(ASPELL)
if(ASPELL_FOUND)
    list(APPEND INKSCAPE_INCS_SYS ${ASPELL_INCLUDE_DIR})
    list(APPEND INKSCAPE_LIBS     ${ASPELL_LIBRARIES})
    add_definitions(${ASPELL_DEFINITIONS})
    set(HAVE_ASPELL TRUE)
endif()

if("${TRY_GTKSPELL}" AND "${WITH_GTKSPELL}")
    find_package(GtkSpell)
    if(GTKSPELL_FOUND)
	list(APPEND INKSCAPE_INCS_SYS ${GTKSPELL_INCLUDE_DIR})
	list(APPEND INKSCAPE_LIBS     ${GTKSPELL_LIBRARIES})
	add_definitions(${GTKSPELL_DEFINITIONS})
    else()
	set(WITH_GTKSPELL OFF)
    endif()
endif()

#find_package(OpenSSL)
#list(APPEND INKSCAPE_INCS_SYS ${OPENSSL_INCLUDE_DIR})
#list(APPEND INKSCAPE_LIBS ${OPENSSL_LIBRARIES})

find_package(LibXslt REQUIRED)
list(APPEND INKSCAPE_INCS_SYS ${LIBXSLT_INCLUDE_DIR})
list(APPEND INKSCAPE_LIBS ${LIBXSLT_LIBRARIES})
add_definitions(${LIBXSLT_DEFINITIONS})

find_package(LibXml2 REQUIRED)
list(APPEND INKSCAPE_INCS_SYS ${LIBXML2_INCLUDE_DIR})
list(APPEND INKSCAPE_LIBS ${LIBXML2_LIBRARIES})
add_definitions(${LIBXML2_DEFINITIONS})

if(WITH_OPENMP)
    find_package(OpenMP)
    if(OPENMP_FOUND)
	set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${OpenMP_C_FLAGS}")
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${OpenMP_CXX_FLAGS}")
	if(APPLE AND ${CMAKE_GENERATOR} MATCHES "Xcode")
	    set(CMAKE_XCODE_ATTRIBUTE_ENABLE_OPENMP_SUPPORT "YES")
	endif()
	mark_as_advanced(OpenMP_C_FLAGS)
	mark_as_advanced(OpenMP_CXX_FLAGS)
	# '-fopenmp' is in OpenMP_C_FLAGS, OpenMP_CXX_FLAGS and implies '-lgomp'
	# uncomment explicit linking below if still needed:
	set(HAVE_OPENMP ON)
	#list(APPEND INKSCAPE_LIBS "-lgomp")  # FIXME
    else()
	set(HAVE_OPENMP OFF)
	set(WITH_OPENMP OFF)
    endif()
endif()

find_package(ZLIB REQUIRED)
list(APPEND INKSCAPE_INCS_SYS ${ZLIB_INCLUDE_DIRS})
list(APPEND INKSCAPE_LIBS ${ZLIB_LIBRARIES})

if(WITH_IMAGE_MAGICK)
    find_package(ImageMagick COMPONENTS MagickCore Magick++)
    if(ImageMagick_FOUND)
	# the component-specific paths apparently fail to get detected correctly
	# on some linux distros (or with older Cmake versions).
	# Use variables which list all include dirs and libraries instead:
	list(APPEND INKSCAPE_INCS_SYS ${ImageMagick_INCLUDE_DIRS})
	list(APPEND INKSCAPE_LIBS ${ImageMagick_LIBRARIES})
	# TODO: Cmake's ImageMagick module misses required defines for newer
	# versions of ImageMagick. See also:
	# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=776832
	#add_definitions(-DMAGICKCORE_HDRI_ENABLE=0)  # FIXME (version check?)
	#add_definitions(-DMAGICKCORE_QUANTUM_DEPTH=16)  # FIXME (version check?)
    else()
	set(WITH_IMAGE_MAGICK OFF)  # enable 'Extensions > Raster'
    endif()
endif()

set(ENABLE_NLS OFF)
if(WITH_NLS)
    find_package(Gettext)
    if(GETTEXT_FOUND)
	message(STATUS "Found gettext + msgfmt to convert language files. Translation enabled")
	set(ENABLE_NLS ON)
    else(GETTEXT_FOUND)
	message(STATUS "Cannot find gettext + msgfmt to convert language file. Translation won't be enabled")
    endif(GETTEXT_FOUND)
endif(WITH_NLS)

find_package(SigC++ REQUIRED)

# end Dependencies

list(REMOVE_DUPLICATES INKSCAPE_LIBS)
list(REMOVE_DUPLICATES INKSCAPE_INCS_SYS)

# C/C++ Flags
include_directories(${INKSCAPE_INCS})
include_directories(SYSTEM ${INKSCAPE_INCS_SYS})

include(${CMAKE_CURRENT_LIST_DIR}/ConfigChecks.cmake)

unset(INKSCAPE_INCS)
unset(INKSCAPE_INCS_SYS)
