
{.emit:"#include \"Remotery.h\""}

{.compile: "Remotery.c"}

type rmtBool* = cuint
const RMT_TRUE* = 1'u32
const RMT_FALSE* = 0'u32

type
    rmtU8* = uint8
    rmtU16* = uint16
    rmtU32* = uint32
    rmtU64* = uint64

    rmtS8* = int8
    rmtS16* = int16
    rmtS32* = int32
    rmtS64* = int64

    rmtPStr* = cstring

    Remotery* = object

    rmtError* = enum
        RMT_ERROR_NONE
        ## System errors
        RMT_ERROR_MALLOC_FAIL                      ## Malloc call within remotery failed
        RMT_ERROR_TLS_ALLOC_FAIL                   ## Attempt to allocate thread local storage failed
        RMT_ERROR_VIRTUAL_MEMORY_BUFFER_FAIL       ## Failed to create a virtual memory mirror buffer
        RMT_ERROR_CREATE_THREAD_FAIL               ## Failed to create a thread for the server
        ## Network TCP/IP socket errors
        RMT_ERROR_SOCKET_INIT_NETWORK_FAIL         ## Network initialisation failure (e.g. on Win32, WSAStartup fails)
        RMT_ERROR_SOCKET_CREATE_FAIL               ## Can't create a socket for connection to the remote viewer
        RMT_ERROR_SOCKET_BIND_FAIL                 ## Can't bind a socket for the server
        RMT_ERROR_SOCKET_LISTEN_FAIL               ## Created server socket failed to enter a listen state
        RMT_ERROR_SOCKET_SET_NON_BLOCKING_FAIL     ## Created server socket failed to switch to a non-blocking state
        RMT_ERROR_SOCKET_INVALID_POLL              ## Poll attempt on an invalid socket
        RMT_ERROR_SOCKET_SELECT_FAIL               ## Server failed to call select on socket
        RMT_ERROR_SOCKET_POLL_ERRORS               ## Poll notified that the socket has errors
        RMT_ERROR_SOCKET_ACCEPT_FAIL               ## Server failed to accept connection from client
        RMT_ERROR_SOCKET_SEND_TIMEOUT              ## Timed out trying to send data
        RMT_ERROR_SOCKET_SEND_FAIL                 ## Unrecoverable error occured while client/server tried to send data
        RMT_ERROR_SOCKET_RECV_NO_DATA              ## No data available when attempting a receive
        RMT_ERROR_SOCKET_RECV_TIMEOUT              ## Timed out trying to receive data
        RMT_ERROR_SOCKET_RECV_FAILED               ## Unrecoverable error occured while client/server tried to receive data
        ## WebSocket errors
        RMT_ERROR_WEBSOCKET_HANDSHAKE_NOT_GET      ## WebSocket server handshake failed, not HTTP GET
        RMT_ERROR_WEBSOCKET_HANDSHAKE_NO_VERSION   ## WebSocket server handshake failed, can't locate WebSocket version
        RMT_ERROR_WEBSOCKET_HANDSHAKE_BAD_VERSION  ## WebSocket server handshake failed, unsupported WebSocket version
        RMT_ERROR_WEBSOCKET_HANDSHAKE_NO_HOST      ## WebSocket server handshake failed, can't locate host
        RMT_ERROR_WEBSOCKET_HANDSHAKE_BAD_HOST     ## WebSocket server handshake failed, host is not allowed to connect
        RMT_ERROR_WEBSOCKET_HANDSHAKE_NO_KEY       ## WebSocket server handshake failed, can't locate WebSocket key
        RMT_ERROR_WEBSOCKET_HANDSHAKE_BAD_KEY      ## WebSocket server handshake failed, WebSocket key is ill-formed
        RMT_ERROR_WEBSOCKET_HANDSHAKE_STRING_FAIL  ## WebSocket server handshake failed, internal error, bad string code
        RMT_ERROR_WEBSOCKET_DISCONNECTED           ## WebSocket server received a disconnect request and closed the socket
        RMT_ERROR_WEBSOCKET_BAD_FRAME_HEADER       ## Couldn't parse WebSocket frame header
        RMT_ERROR_WEBSOCKET_BAD_FRAME_HEADER_SIZE  ## Partially received wide frame header size
        RMT_ERROR_WEBSOCKET_BAD_FRAME_HEADER_MASK  ## Partially received frame header data mask
        RMT_ERROR_WEBSOCKET_RECEIVE_TIMEOUT        ## Timeout receiving frame header
        RMT_ERROR_REMOTERY_NOT_CREATED             ## Remotery object has not been created
        RMT_ERROR_SEND_ON_INCOMPLETE_PROFILE       ## An attempt was made to send an incomplete profile tree to the client
        ## CUDA error messages
        RMT_ERROR_CUDA_DEINITIALIZED               ## This indicates that the CUDA driver is in the process of shutting down
        RMT_ERROR_CUDA_NOT_INITIALIZED             ## This indicates that the CUDA driver has not been initialized with cuInit() or that initialization has failed
        RMT_ERROR_CUDA_INVALID_CONTEXT             ## This most frequently indicates that there is no context bound to the current thread
        RMT_ERROR_CUDA_INVALID_VALUE               ## This indicates that one or more of the parameters passed to the API call is not within an acceptable range of values
        RMT_ERROR_CUDA_INVALID_HANDLE              ## This indicates that a resource handle passed to the API call was not valid
        RMT_ERROR_CUDA_OUT_OF_MEMORY               ## The API call failed because it was unable to allocate enough memory to perform the requested operation
        RMT_ERROR_ERROR_NOT_READY                  ## This indicates that a resource handle passed to the API call was not valid
        ## Direct3D 11 error messages
        RMT_ERROR_D3D11_FAILED_TO_CREATE_QUERY     ## Failed to create query for sample
        ## OpenGL error messages
        RMT_ERROR_OPENGL_ERROR                     ## Generic OpenGL error, no real need to expose more detail since app will probably have an OpenGL error callback registered
        RMT_ERROR_CUDA_UNKNOWN

    rmtSampleFlags* = enum
        RMTSF_None = 0
        RMTSF_Aggregate = 1

    rmtMallocPtr* = ptr proc(mm_context: pointer, size: rmtU32): pointer
    rmtReallocPtr* = ptr proc(mm_context: pointer, pntr: pointer, size: rmtU32): pointer
    rmtFreePtr* = ptr proc(mm_context: pointer, pntr: pointer)
    rmtInputHandlerPtr* = ptr proc(text: cstring, context: pointer)

    rmtSettings* = object
        port: rmtU16
        limit_connections_to_localhost: rmtBool
        msSleepBetweenServerUpdates: rmtU32
        messageQueueSizeInBytes: rmtU32
        maxNbMessagesPerUpdate: rmtU32
        malloc: rmtMallocPtr
        realloc: rmtReallocPtr
        free: rmtFreePtr
        mm_context: pointer
        input_handler: rmtInputHandlerPtr
        input_handler_context: pointer
        logFilename: rmtPStr

    rmtCUDABind* = object
        context: pointer
        CtxSetCurrent: pointer
        CtxGetCurrent: pointer
        EventCreate: pointer
        EventDestroy: pointer
        EventRecord: pointer
        EventQuery: pointer
        EventElapsedTime: pointer

proc Settings*(): ptr rmtSettings =
    when defined(RMT_ENABLED):
        {.emit:"return _rmt_Settings();"}
    else:
        return nil

proc CreateGlobalInstance*(remotery: ptr ptr Remotery): rmtError =
    when defined(RMT_ENABLED):
        {.emit:"return _rmt_CreateGlobalInstance(`remotery`);"}
    else:
        return RMT_ERROR_NONE

proc DestroyGlobalInstance*(remotery: ptr Remotery) =
    when defined(RMT_ENABLED):
        {.emit:"_rmt_DestroyGlobalInstance(`remotery`);"}
    else:
        discard

proc SetGlobalInstance*(remotery: ptr Remotery) =
    when defined(RMT_ENABLED):
        {.emit:"_rmt_SetGlobalInstance(`remotery`);"}
    else:
        discard

proc GetGlobalInstance*(): ptr Remotery =
    when defined(RMT_ENABLED):
        {.emit:"return _rmt_GetGlobalInstance();"}
    else:
        return nil

proc SetCurrentThreadName*(thread_name: rmtPStr) =
    when defined(RMT_ENABLED):
        {.emit:"_rmt_SetCurrentThreadName(`thread_name`);"}
    else:
        discard

proc LogText*(text: rmtPStr) =
    when defined(RMT_ENABLED):
        {.emit:"_rmt_LogText(`text`);"}
    else:
        discard

proc BeginCPUSample*(name: rmtPStr, flags: rmtU32 , hash_cache: ptr rmtU32 ) =
    when defined(RMT_ENABLED):
        {.emit:"_rmt_BeginCPUSample(`name`, flags, hash_cache);"}
    else:
        discard

proc EndCPUSample*() =
    when defined(RMT_ENABLED):
        {.emit:"_rmt_EndCPUSample();"}
    else:
        discard

proc BindCUDA*(CUDAbind: ptr rmtCUDABind) =
    when defined(RMT_USE_CUDA):
        {.emit:"_rmt_BindCUDA(`CUDAbind`);"}
    else:
        discard

proc BeginCUDASample*(name: rmtPStr, hash_cache: ptr rmtU32, stream: pointer) =
    when defined(RMT_USE_CUDA):
        {.emit:"_rmt_BindCUDA(`name`, `hash_cache`, `stream`);"}
    else:
        discard

proc EndCUDASample*(stream: pointer) =
    when defined(RMT_USE_CUDA):
        {.emit:"_rmt_EndCUDASample(`stream`);"}
    else:
        discard

proc BindD3D11*(device, context: pointer) =
    when defined(RMT_USE_D3D11):
        {.emit:"_rmt_BindD3D11(`device`, `context`);"}
    else:
        discard

proc UnbindD3D11*() =
    when defined(RMT_USE_D3D11):
        {.emit:"_rmt_UnbindD3D11();"}
    else:
        discard

proc BeginD3D11Sample*(name: rmtPStr, hash_cache: ptr rmtU32) =
    when defined(RMT_USE_D3D11):
        {.emit:"_rmt_BeginD3D11Sample(`name`, `hash_cache`);"}
    else:
        discard

proc EndD3D11Sample*(name: rmtPStr, hash_cache: ptr rmtU32) =
    when defined(RMT_USE_D3D11):
        {.emit:"_rmt_EndD3D11Sample();"}
    else:
        discard

proc BindOpenGL*() =
    when defined(RMT_USE_OPENGL):
        {.emit:"_rmt_BindOpenGL();"}
    else:
        discard

proc UnbindOpenGL*() =
    when defined(RMT_USE_OPENGL):
        {.emit:"_rmt_BindOpenGL();"}
    else:
        discard

proc BeginOpenGLSample*(name: rmtPStr, hash_cache: ptr rmtU32) =
    when defined(RMT_USE_OPENGL):
        {.emit:"_rmt_BeginOpenGLSample(`name`, `hash_cache`);"}
    else:
        discard

proc EndOpenGLSample*() =
    when defined(RMT_USE_OPENGL):
        {.emit:"_rmt_EndOpenGLSample();"}
    else:
        discard
