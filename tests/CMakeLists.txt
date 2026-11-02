find_package(Qt6Test ${QT_MIN_VERSION} REQUIRED)

add_executable(test_kimageplayground test_kimageplayground.cpp)
target_compile_definitions(test_kimageplayground PRIVATE KIMAGEPLAYGROUND_SOURCE_DIR="${CMAKE_SOURCE_DIR}")
target_link_libraries(test_kimageplayground PRIVATE
    kimageplayground_core
    Qt6::Core
    Qt6::Test
)

add_test(NAME test_kimageplayground COMMAND test_kimageplayground)
