	.arch armv7-a
	.eabi_attribute 28, 1
	.eabi_attribute 23, 1
	.eabi_attribute 24, 1
	.eabi_attribute 25, 1
	.eabi_attribute 26, 2
	.eabi_attribute 30, 2
	.eabi_attribute 34, 1
	.eabi_attribute 18, 4
	.file	"meanFilterMPU6050.c"
	.text
	.align	1
	.p2align 2,,3
	.global	filtro_media_movil_MPU6050
	.arch armv7-a
	.syntax unified
	.thumb
	.thumb_func
	.fpu vfpv3-d16
	.type	filtro_media_movil_MPU6050, %function
filtro_media_movil_MPU6050:
	@ args = 0, pretend = 0, frame = 32
	@ frame_needed = 0, uses_anonymous_args = 0
	@ link register save eliminated.
	push	{r4, r5, r6}
	cmp	r2, #0
	vpush.64	{d8, d9, d10, d11, d12, d13, d14, d15}
	vmov	s29, r1	@ int
	sub	sp, sp, #36
	ble	.L2
	vmov.f64	d10, #4.75e+0
	movs	r4, #0
	vldr.32	s27, .L7+40
	vldr.64	d9, .L7
	vldr.64	d8, .L7+8
	vmov.f64	d0, #2.5e+0
	vldr.64	d1, .L7+16
	vldr.32	s28, .L7+44
	vldr.64	d2, .L7+24
	vldr.32	s26, .L7+48
.L3:
	ldrb	r1, [r0]	@ zero_extendqisi2
	adds	r4, r4, #14
	ldrb	r3, [r0, #1]	@ zero_extendqisi2
	cmp	r2, r4
	vldr.32	s30, [sp, #4]
	add	r0, r0, #14
	orr	r3, r3, r1, lsl #8
	ldrb	r5, [r0, #-12]	@ zero_extendqisi2
	ldrb	r1, [r0, #-10]	@ zero_extendqisi2
	vmov	s24, r3	@ int
	ldrb	r3, [r0, #-11]	@ zero_extendqisi2
	vcvt.f64.f32	d15, s30
	ldrb	r6, [r0, #-4]	@ zero_extendqisi2
	orr	r3, r3, r5, lsl #8
	ldrb	r5, [r0, #-8]	@ zero_extendqisi2
	vldr.64	d3, .L7+32
	vmov	s22, r3	@ int
	ldrb	r3, [r0, #-9]	@ zero_extendqisi2
	vcvt.f32.u32	s24, s24
	orr	r3, r3, r1, lsl #8
	ldrb	r1, [r0, #-6]	@ zero_extendqisi2
	vmov	s8, r3	@ int
	ldrb	r3, [r0, #-7]	@ zero_extendqisi2
	orr	r3, r3, r5, lsl #8
	ldrb	r5, [r0, #-2]	@ zero_extendqisi2
	vmov	s10, r3	@ int
	ldrb	r3, [r0, #-5]	@ zero_extendqisi2
	vmul.f32	s24, s24, s27
	orr	r3, r3, r1, lsl #8
	ldrb	r1, [r0, #-3]	@ zero_extendqisi2
	vmov	s12, r3	@ int
	orr	r3, r1, r6, lsl #8
	vmov	s14, r3	@ int
	ldrb	r3, [r0, #-1]	@ zero_extendqisi2
	orr	r3, r3, r5, lsl #8
	vsub.f64	d15, d15, d9
	vcvt.f64.f32	d12, s24
	vadd.f64	d12, d12, d15
	vcvt.f32.f64	s24, d12
	vcvt.f32.u32	s22, s22
	vstr.32	s24, [sp, #4]
	vldr.32	s24, [sp, #8]
	vmul.f32	s22, s22, s27
	vcvt.f64.f32	d12, s24
	vadd.f64	d12, d12, d8
	vcvt.f64.f32	d11, s22
	vadd.f64	d11, d11, d12
	vcvt.f32.f64	s22, d11
	vcvt.f32.u32	s8, s8
	vstr.32	s22, [sp, #8]
	vldr.32	s22, [sp, #12]
	vmul.f32	s8, s8, s27
	vcvt.f64.f32	d11, s22
	vsub.f64	d11, d11, d1
	vcvt.f64.f32	d4, s8
	vadd.f64	d4, d4, d11
	vcvt.f32.f64	s8, d4
	vcvt.f32.u32	s10, s10
	vstr.32	s8, [sp, #12]
	vldr.32	s8, [sp, #16]
	vmul.f32	s10, s10, s28
	vcvt.f64.f32	d4, s8
	vadd.f64	d4, d4, d2
	vcvt.f64.f32	d5, s10
	vadd.f64	d5, d5, d4
	vcvt.f32.f64	s10, d5
	vcvt.f32.u32	s12, s12
	vstr.32	s10, [sp, #16]
	vldr.32	s10, [sp, #20]
	vmul.f32	s12, s12, s26
	vcvt.f64.f32	d5, s10
	vsub.f64	d5, d5, d10
	vcvt.f64.f32	d6, s12
	vadd.f64	d6, d6, d5
	vcvt.f32.f64	s12, d6
	vcvt.f32.u32	s14, s14
	vstr.32	s12, [sp, #20]
	vldr.32	s12, [sp, #24]
	vmul.f32	s14, s14, s26
	vcvt.f64.f32	d6, s12
	vsub.f64	d6, d6, d0
	vcvt.f64.f32	d7, s14
	vadd.f64	d7, d7, d6
	vcvt.f32.f64	s14, d7
	vmov	s15, r3	@ int
	vcvt.f32.u32	s13, s15
	vstr.32	s14, [sp, #24]
	vldr.32	s14, [sp, #28]
	vmul.f32	s13, s13, s26
	vcvt.f64.f32	d7, s14
	vsub.f64	d7, d7, d3
	vcvt.f64.f32	d3, s13
	vadd.f64	d3, d3, d7
	vcvt.f32.f64	s6, d3
	vstr.32	s6, [sp, #28]
	bgt	.L3
.L2:
	vmov.f32	s13, #1.0e+0
	vldr.32	s14, [sp, #4]
	vcvt.f32.s32	s29, s29
	vdiv.f32	s15, s13, s29
	vmul.f32	s14, s15, s14
	vstr.32	s14, [sp, #4]
	vldr.32	s14, [sp, #8]
	vmul.f32	s14, s15, s14
	vstr.32	s14, [sp, #8]
	vldr.32	s14, [sp, #12]
	vmul.f32	s14, s15, s14
	vstr.32	s14, [sp, #12]
	vldr.32	s14, [sp, #16]
	vmul.f32	s14, s15, s14
	vstr.32	s14, [sp, #16]
	vldr.32	s14, [sp, #20]
	vmul.f32	s14, s15, s14
	vstr.32	s14, [sp, #20]
	vldr.32	s14, [sp, #24]
	vmul.f32	s14, s15, s14
	vstr.32	s14, [sp, #24]
	vldr.32	s14, [sp, #28]
	vmul.f32	s15, s15, s14
	vstr.32	s15, [sp, #28]
	add	sp, sp, #36
	@ sp needed
	vldm	sp!, {d8-d15}
	pop	{r4, r5, r6}
	bx	lr
.L8:
	.align	3
.L7:
	.word	1202590843
	.word	1066695393
	.word	-343597384
	.word	1068415057
	.word	-1717986918
	.word	1068079513
	.word	171798692
	.word	1078084567
	.word	858993459
	.word	1071854387
	.word	947912704
	.word	994099393
	.word	1006239744
	.size	filtro_media_movil_MPU6050, .-filtro_media_movil_MPU6050
	.ident	"GCC: (Debian 8.3.0-6) 8.3.0"
	.section	.note.GNU-stack,"",%progbits
