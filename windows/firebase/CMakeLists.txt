cmake_minimum_required(VERSION 3.14)
project(firebase_windows LANGUAGES CXX)

# Firebase Core
add_library(firebase_core_plugin SHARED IMPORTED)
set_target_properties(firebase_core_plugin PROPERTIES
  IMPORTED_LOCATION "${CMAKE_CURRENT_SOURCE_DIR}/lib/firebase_core.dll"
  IMPORTED_IMPLIB "${CMAKE_CURRENT_SOURCE_DIR}/lib/firebase_core.lib"
)

# Firebase Auth
add_library(firebase_auth_plugin SHARED IMPORTED)
set_target_properties(firebase_auth_plugin PROPERTIES
  IMPORTED_LOCATION "${CMAKE_CURRENT_SOURCE_DIR}/lib/firebase_auth.dll"
  IMPORTED_IMPLIB "${CMAKE_CURRENT_SOURCE_DIR}/lib/firebase_auth.lib"
)

# Firebase Storage
add_library(firebase_storage_plugin SHARED IMPORTED)
set_target_properties(firebase_storage_plugin PROPERTIES
  IMPORTED_LOCATION "${CMAKE_CURRENT_SOURCE_DIR}/lib/firebase_storage.dll"
  IMPORTED_IMPLIB "${CMAKE_CURRENT_SOURCE_DIR}/lib/firebase_storage.lib"
)

# Firebase Firestore
add_library(firebase_firestore_plugin SHARED IMPORTED)
set_target_properties(firebase_firestore_plugin PROPERTIES
  IMPORTED_LOCATION "${CMAKE_CURRENT_SOURCE_DIR}/lib/firebase_firestore.dll"
  IMPORTED_IMPLIB "${CMAKE_CURRENT_SOURCE_DIR}/lib/firebase_firestore.lib"
)
