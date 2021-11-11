	.arch armv7-a
	.eabi_attribute 28, 1
	.eabi_attribute 20, 1
	.eabi_attribute 21, 1
	.eabi_attribute 23, 3
	.eabi_attribute 24, 1
	.eabi_attribute 25, 1
	.eabi_attribute 26, 2
	.eabi_attribute 30, 6
	.eabi_attribute 34, 1
	.eabi_attribute 18, 4
	.file	"meanFilterMPU6050.c"
	.text
	.align	1
	.global	filtro_MPU6050
	.arch armv7-a
	.syntax unified
	.thumb
	.thumb_func
	.fpu vfpv3-d16
	.type	filtro_MPU6050, %function
filtro_MPU6050:
	@ args = 0, pretend = 0, frame = 56
	@ frame_needed = 1, uses_anonymous_args = 0
	@ link register save eliminated.
	push	{r4, r5, r7}
	sub	sp, sp, #60
	add	r7, sp, #0
	str	r0, [r7, #12]
	str	r1, [r7, #8]
	str	r2, [r7, #4]
	str	r3, [r7]
	movs	r3, #0
	str	r3, [r7, #52]
	add	r3, r7, #20
	movs	r2, #0
	str	r2, [r3]
	str	r2, [r3, #4]
	str	r2, [r3, #8]
	str	r2, [r3, #12]
	str	r2, [r3, #16]
	str	r2, [r3, #20]
	str	r2, [r3, #24]
	b	.L2
.L3:
	ldr	r3, [r7, #52]
	ldr	r2, [r7, #8]
	add	r3, r3, r2
	ldrb	r3, [r3]	@ zero_extendqisi2
	lsls	r3, r3, #8
	sxth	r2, r3
	ldr	r3, [r7, #52]
	adds	r3, r3, #1
	ldr	r1, [r7, #8]
	add	r3, r3, r1
	ldrb	r3, [r3]	@ zero_extendqisi2
	sxth	r3, r3
	orrs	r3, r3, r2
	strh	r3, [r7, #50]	@ movhi
	vldr.32	s15, [r7, #20]
	vcvt.f64.f32	d6, s15
	ldrsh	r3, [r7, #50]
	vmov	s15, r3	@ int
	vcvt.f32.s32	s15, s15
	vadd.f32	s14, s15, s15
	vldr.32	s11, .L5+40
	vdiv.f32	s15, s14, s11
	vcvt.f64.f32	d7, s15
	vldr.64	d5, .L5
	vsub.f64	d7, d7, d5
	vadd.f64	d7, d6, d7
	vcvt.f32.f64	s15, d7
	vstr.32	s15, [r7, #20]
	ldr	r3, [r7, #52]
	adds	r3, r3, #2
	ldr	r2, [r7, #8]
	add	r3, r3, r2
	ldrb	r3, [r3]	@ zero_extendqisi2
	lsls	r3, r3, #8
	sxth	r2, r3
	ldr	r3, [r7, #52]
	adds	r3, r3, #3
	ldr	r1, [r7, #8]
	add	r3, r3, r1
	ldrb	r3, [r3]	@ zero_extendqisi2
	sxth	r3, r3
	orrs	r3, r3, r2
	strh	r3, [r7, #50]	@ movhi
	vldr.32	s15, [r7, #24]
	vcvt.f64.f32	d6, s15
	ldrsh	r3, [r7, #50]
	vmov	s15, r3	@ int
	vcvt.f32.s32	s15, s15
	vadd.f32	s14, s15, s15
	vldr.32	s11, .L5+40
	vdiv.f32	s15, s14, s11
	vcvt.f64.f32	d7, s15
	vldr.64	d5, .L5+8
	vadd.f64	d7, d7, d5
	vadd.f64	d7, d6, d7
	vcvt.f32.f64	s15, d7
	vstr.32	s15, [r7, #24]
	ldr	r3, [r7, #52]
	adds	r3, r3, #4
	ldr	r2, [r7, #8]
	add	r3, r3, r2
	ldrb	r3, [r3]	@ zero_extendqisi2
	lsls	r3, r3, #8
	sxth	r2, r3
	ldr	r3, [r7, #52]
	adds	r3, r3, #5
	ldr	r1, [r7, #8]
	add	r3, r3, r1
	ldrb	r3, [r3]	@ zero_extendqisi2
	sxth	r3, r3
	orrs	r3, r3, r2
	strh	r3, [r7, #50]	@ movhi
	vldr.32	s15, [r7, #28]
	vcvt.f64.f32	d6, s15
	ldrsh	r3, [r7, #50]
	vmov	s15, r3	@ int
	vcvt.f32.s32	s15, s15
	vadd.f32	s14, s15, s15
	vldr.32	s11, .L5+40
	vdiv.f32	s15, s14, s11
	vcvt.f64.f32	d7, s15
	vldr.64	d5, .L5+16
	vsub.f64	d7, d7, d5
	vadd.f64	d7, d6, d7
	vcvt.f32.f64	s15, d7
	vstr.32	s15, [r7, #28]
	ldr	r3, [r7, #52]
	adds	r3, r3, #6
	ldr	r2, [r7, #8]
	add	r3, r3, r2
	ldrb	r3, [r3]	@ zero_extendqisi2
	lsls	r3, r3, #8
	sxth	r2, r3
	ldr	r3, [r7, #52]
	adds	r3, r3, #7
	ldr	r1, [r7, #8]
	add	r3, r3, r1
	ldrb	r3, [r3]	@ zero_extendqisi2
	sxth	r3, r3
	orrs	r3, r3, r2
	strh	r3, [r7, #50]	@ movhi
	vldr.32	s15, [r7, #32]
	vcvt.f64.f32	d6, s15
	ldrsh	r3, [r7, #50]
	vmov	s15, r3	@ int
	vcvt.f32.s32	s14, s15
	vldr.32	s11, .L5+44
	vdiv.f32	s15, s14, s11
	vcvt.f64.f32	d7, s15
	vldr.64	d5, .L5+24
	vadd.f64	d7, d7, d5
	vadd.f64	d7, d6, d7
	vcvt.f32.f64	s15, d7
	vstr.32	s15, [r7, #32]
	ldr	r3, [r7, #52]
	adds	r3, r3, #8
	ldr	r2, [r7, #8]
	add	r3, r3, r2
	ldrb	r3, [r3]	@ zero_extendqisi2
	lsls	r3, r3, #8
	sxth	r2, r3
	ldr	r3, [r7, #52]
	adds	r3, r3, #9
	ldr	r1, [r7, #8]
	add	r3, r3, r1
	ldrb	r3, [r3]	@ zero_extendqisi2
	sxth	r3, r3
	orrs	r3, r3, r2
	strh	r3, [r7, #50]	@ movhi
	vldr.32	s15, [r7, #36]
	vcvt.f64.f32	d6, s15
	ldrsh	r3, [r7, #50]
	vmov	s15, r3	@ int
	vcvt.f32.s32	s15, s15
	vldr.32	s14, .L5+48
	vmul.f32	s14, s15, s14
	vldr.32	s11, .L5+40
	vdiv.f32	s15, s14, s11
	vcvt.f64.f32	d7, s15
	vmov.f64	d5, #4.75e+0
	vsub.f64	d7, d7, d5
	vadd.f64	d7, d6, d7
	vcvt.f32.f64	s15, d7
	vstr.32	s15, [r7, #36]
	ldr	r3, [r7, #52]
	adds	r3, r3, #10
	ldr	r2, [r7, #8]
	add	r3, r3, r2
	ldrb	r3, [r3]	@ zero_extendqisi2
	lsls	r3, r3, #8
	sxth	r2, r3
	ldr	r3, [r7, #52]
	adds	r3, r3, #11
	ldr	r1, [r7, #8]
	add	r3, r3, r1
	ldrb	r3, [r3]	@ zero_extendqisi2
	sxth	r3, r3
	orrs	r3, r3, r2
	strh	r3, [r7, #50]	@ movhi
	vldr.32	s15, [r7, #40]
	vcvt.f64.f32	d6, s15
	ldrsh	r3, [r7, #50]
	vmov	s15, r3	@ int
	vcvt.f32.s32	s15, s15
	vldr.32	s14, .L5+48
	vmul.f32	s14, s15, s14
	vldr.32	s11, .L5+40
	vdiv.f32	s15, s14, s11
	vcvt.f64.f32	d7, s15
	vmov.f64	d5, #2.5e+0
	vsub.f64	d7, d7, d5
	vadd.f64	d7, d6, d7
	vcvt.f32.f64	s15, d7
	vstr.32	s15, [r7, #40]
	ldr	r3, [r7, #52]
	adds	r3, r3, #12
	ldr	r2, [r7, #8]
	add	r3, r3, r2
	ldrb	r3, [r3]	@ zero_extendqisi2
	lsls	r3, r3, #8
	sxth	r2, r3
	ldr	r3, [r7, #52]
	adds	r3, r3, #13
	ldr	r1, [r7, #8]
	add	r3, r3, r1
	ldrb	r3, [r3]	@ zero_extendqisi2
	sxth	r3, r3
	orrs	r3, r3, r2
	strh	r3, [r7, #50]	@ movhi
	vldr.32	s15, [r7, #44]
	vcvt.f64.f32	d6, s15
	ldrsh	r3, [r7, #50]
	vmov	s15, r3	@ int
	vcvt.f32.s32	s15, s15
	vldr.32	s14, .L5+48
	vmul.f32	s14, s15, s14
	vldr.32	s11, .L5+40
	vdiv.f32	s15, s14, s11
	vcvt.f64.f32	d7, s15
	vldr.64	d5, .L5+32
	vsub.f64	d7, d7, d5
	vadd.f64	d7, d6, d7
	vcvt.f32.f64	s15, d7
	vstr.32	s15, [r7, #44]
	ldr	r3, [r7, #52]
	adds	r3, r3, #14
	str	r3, [r7, #52]
.L2:
	ldr	r2, [r7, #52]
	ldr	r3, [r7]
	cmp	r2, r3
	blt	.L3
	vldr.32	s13, [r7, #20]
	ldr	r3, [r7, #4]
	vmov	s15, r3	@ int
	vcvt.f32.s32	s14, s15
	vdiv.f32	s15, s13, s14
	vstr.32	s15, [r7, #20]
	vldr.32	s13, [r7, #24]
	ldr	r3, [r7, #4]
	vmov	s15, r3	@ int
	vcvt.f32.s32	s14, s15
	vdiv.f32	s15, s13, s14
	vstr.32	s15, [r7, #24]
	vldr.32	s13, [r7, #28]
	ldr	r3, [r7, #4]
	vmov	s15, r3	@ int
	vcvt.f32.s32	s14, s15
	vdiv.f32	s15, s13, s14
	vstr.32	s15, [r7, #28]
	vldr.32	s13, [r7, #32]
	ldr	r3, [r7, #4]
	vmov	s15, r3	@ int
	vcvt.f32.s32	s14, s15
	vdiv.f32	s15, s13, s14
	vstr.32	s15, [r7, #32]
	vldr.32	s13, [r7, #36]
	ldr	r3, [r7, #4]
	vmov	s15, r3	@ int
	vcvt.f32.s32	s14, s15
	vdiv.f32	s15, s13, s14
	vstr.32	s15, [r7, #36]
	vldr.32	s13, [r7, #40]
	ldr	r3, [r7, #4]
	vmov	s15, r3	@ int
	vcvt.f32.s32	s14, s15
	vdiv.f32	s15, s13, s14
	vstr.32	s15, [r7, #40]
	vldr.32	s13, [r7, #44]
	ldr	r3, [r7, #4]
	vmov	s15, r3	@ int
	vcvt.f32.s32	s14, s15
	vdiv.f32	s15, s13, s14
	vstr.32	s15, [r7, #44]
	ldr	r3, [r7, #12]
	mov	r5, r3
	add	r4, r7, #20
	ldmia	r4!, {r0, r1, r2, r3}
	stmia	r5!, {r0, r1, r2, r3}
	ldm	r4, {r0, r1, r2}
	stm	r5, {r0, r1, r2}
	ldr	r0, [r7, #12]
	adds	r7, r7, #60
	mov	sp, r7
	@ sp needed
	pop	{r4, r5, r7}
	bx	lr
.L6:
	.align	3
.L5:
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
	.word	1191182336
	.word	1135214592
	.word	1132068864
	.size	filtro_MPU6050, .-filtro_MPU6050
	.ident	"GCC: (Debian 8.3.0-6) 8.3.0"
	.section	.note.GNU-stack,"",%progbits
