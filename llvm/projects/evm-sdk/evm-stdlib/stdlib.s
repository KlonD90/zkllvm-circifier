    .file	"memory.S"

.macro STDLIB_FUNC name
	.type	\name,function
	.hidden	\name
\name:
.endm

.macro STDLIB_FUNC_INVALID name
	STDLIB_FUNC \name
	JUMPDEST
    INVALID
.endm

################################ MEMSET ################################
# INPUT STACK: 1:mem, 2:value, 3:count
#
STDLIB_FUNC memset
    JUMPDEST

    # We can use memset label, but then debugger might be confused.
head1:
    JUMPDEST

    # Exit if count is zero
    DUP3
    ISZERO
    PUSH4   exit1
    JUMPI

    # Decrease count variable
    PUSH1 1
    DUP4
    SUB
    SWAP3
    POP

    # Write value to memory
    DUP2    # value
    DUP2    # mem
    MSTORE8

    # Increase memory variable
    DUP1
    PUSH1 1
    ADD
    SWAP1
    POP

    # Jump to loop head
    PUSH4 head1
    JUMP

exit1:
    JUMPDEST
    POP
    POP
    SWAP1
    JUMP

################################ MEMCPY ################################
# INPUT STACK: 1:dst, 2:src, 3:count
# TODO: implement via `identity` precompiled contract
#
STDLIB_FUNC memcpy
    JUMPDEST

# We can use memcpy label, but then debugger might be confused.
head2:
    JUMPDEST

    # Exit if count is zero
    DUP3
    ISZERO
    PUSH4   exit2
    JUMPI

    # Decrease count variable
    PUSH1 1
    DUP4
    SUB
    SWAP3
    POP

    # Copy memory
    DUP2     # src
    MLOAD8
    DUP2     # dst
    MSTORE8

    # Increase dst memory variable
    DUP1
    PUSH1 1
    ADD
    SWAP1
    POP

    # Increase src memory variable
    DUP2
    PUSH1 1
    ADD
    SWAP2
    POP

    # Jump to loop head
    PUSH4 head2
    JUMP

exit2:
    JUMPDEST
    POP
    POP
    # TODO: We should return proper value, i.e. dst address
    #POP
    SWAP1
    JUMP

fail:
    JUMPDEST
    INVALID

################################ EXIT ################################
# INPUT STACK: 1: exit code
#
STDLIB_FUNC exit
    JUMPDEST
    PUSH1 0
    MSTORE
    PUSH1 0x20
    PUSH1 0
    RETURN

######################## __evm_builtin_modpow ########################
# INPUT STACK: 1: base, 2: exp, 3: mod
#
STDLIB_FUNC __evm_builtin_modpow
    JUMPDEST

    PUSH1   0  // FP ADDRESS
    MLOAD

    # Stack: [mod, exp, base, freemem]
    PUSH1 32
    DUP2
    MSTORE

    PUSH1 32
    DUP2
    PUSH1 32
    ADD
    MSTORE

    PUSH1 32
    DUP2
    PUSH1 64
    ADD
    MSTORE

    # Stack: [mod, exp, base, freemem]
    DUP1
    PUSH1 96
    ADD
    # Stack: [mod, exp, base, freemem, addr]
    DUP3
    # Stack: [mod, exp, base, freemem, addr, base]
    SWAP1
    # Stack: [mod, exp, base, freemem, base, addr]
    MSTORE

    # Stack: [mod, exp, base, freemem]
    DUP1
    PUSH1 128
    ADD
    # Stack: [mod, exp, base, freemem, addr]
    DUP4
    # Stack: [mod, exp, base, freemem, addr, exp]
    SWAP1
    # Stack: [mod, exp, base, freemem, exp, addr]
    MSTORE

    # Stack: [mod, exp, base, freemem]
    DUP1
    PUSH1 160
    ADD
    # Stack: [mod, exp, base, freemem, addr]
    DUP5
    # Stack: [mod, exp, base, freemem, addr, mod]
    SWAP1
    # Stack: [mod, exp, base, freemem, mod, addr]
    MSTORE

    # Stack: [mod, exp, base, freemem]
    PUSH1 32
    # Stack: [mod, exp, base, freemem, retSize]
    DUP2
    # Stack: [mod, exp, base, freemem, retSize, retOffset(freemem)]
    PUSH1 192
    # Stack: [mod, exp, base, freemem, retSize, retOffset(freemem), argsSize]
    DUP4
    # Stack: [mod, exp, base, freemem, retSize, retOffset(freemem), argsSize, argsOffset(freemem)]
    PUSH1 5
    # Stack: [mod, exp, base, freemem, retSize, retOffset(freemem), argsSize, argsOffset(freemem), contract]
    GAS
    # Stack: [mod, exp, base, freemem, retSize, retOffset(freemem), argsSize, argsOffset(freemem), contract, gas]
    STATICCALL

    # Stack: [mod, exp, base, freemem, result]
    PUSH4 modpow_cont
    JUMPI
    PUSH4 abort
    JUMP

modpow_cont:
    JUMPDEST

    # Stack: [mod, exp, base, freemem]
    SWAP3
    POP
    POP
    POP
    # Stack: [freemem]
    MLOAD
    # Stack: [result]

    SWAP1
    # Stack: [result, return_address]
    JUMP


# TODO: Implement memmove
STDLIB_FUNC_INVALID memmove

# operator new(unsigned long)
STDLIB_FUNC_INVALID _Znwm
# operator new(unsigned long, std::align_val_t)
STDLIB_FUNC_INVALID _ZnwmSt11align_val_t
# operator delete(unsigned long)
STDLIB_FUNC_INVALID _ZdlPv
# operator delete(void*, std::align_val_t)
STDLIB_FUNC_INVALID _ZdlPvSt11align_val_t
# Exceptions is not supported in EVM
STDLIB_FUNC_INVALID __cxa_allocate_exception
STDLIB_FUNC_INVALID __cxa_begin_catch
STDLIB_FUNC_INVALID __cxa_pure_virtual
STDLIB_FUNC_INVALID __cxa_throw
# STDLIB_FUNC_INVALID _ZTISt14overflow_error
# Assert
STDLIB_FUNC_INVALID _wassert
# std::terminate
STDLIB_FUNC_INVALID _ZSt9terminatev
# abort
STDLIB_FUNC_INVALID abort

STDLIB_FUNC _ZTVN10__cxxabiv121__vmi_class_type_infoE
    STOP # zero

STDLIB_FUNC _ZTVN10__cxxabiv117__class_type_infoE
    STOP # zero
