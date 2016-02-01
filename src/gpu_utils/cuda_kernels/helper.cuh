#ifndef CUDA_HELPER_KERNELS_CUH_
#define CUDA_HELPER_KERNELS_CUH_

#include <cuda_runtime.h>
#include <vector>
#include <iostream>
#include <fstream>
#include "src/gpu_utils/cuda_settings.h"
#include "src/gpu_utils/cuda_device_utils.cuh"
#include "src/gpu_utils/cuda_projector.cuh"
#include "src/gpu_utils/cuda_projector.h"

__global__ void cuda_kernel_exponentiate_weights_coarse(  XFLOAT *g_pdf_orientation,
									    	  XFLOAT *g_pdf_offset,
									    	  XFLOAT *g_Mweight,
									    	  XFLOAT min_diff2,
									     	  int nr_coarse_orient,
									     	  int nr_coarse_trans);

__global__ void cuda_kernel_exponentiate_weights_fine(    XFLOAT *g_pdf_orientation,
											  XFLOAT *g_pdf_offset,
											  XFLOAT *g_weights,
											  XFLOAT min_diff2,
											  int oversamples_orient,
											  int oversamples_trans,
									     	  unsigned long *d_rot_id,
											  unsigned long *d_trans_idx,
											  unsigned long *d_job_idx,
											  unsigned long *d_job_num,
									     	  long int job_num);

__global__ void cuda_kernel_collect2jobs(	XFLOAT *g_oo_otrans_x,          // otrans-size -> make const
										XFLOAT *g_oo_otrans_y,          // otrans-size -> make const
										XFLOAT *g_myp_oo_otrans_x2y2z2, // otrans-size -> make const
										XFLOAT *g_i_weights,
										XFLOAT op_significant_weight,    // TODO Put in const
										XFLOAT op_sum_weight,            // TODO Put in const
										int   coarse_trans,
										int   oversamples_trans,
										int   oversamples_orient,
										int   oversamples,
										bool  do_ignore_pdf_direction,
										XFLOAT *g_o_weights,
										XFLOAT *g_thr_wsum_prior_offsetx_class,
										XFLOAT *g_thr_wsum_prior_offsety_class,
										XFLOAT *g_thr_wsum_sigma2_offset,
								     	unsigned long *d_rot_idx,
								     	unsigned long *d_trans_idx,
								     	unsigned long *d_job_idx,
								     	unsigned long *d_job_num
								     	);

__global__ void cuda_kernel_softMaskOutsideMap(	XFLOAT *vol,
												long int vol_size,
												long int xdim,
												long int ydim,
												long int zdim,
												long int xinit,
												long int yinit,
												long int zinit,
												bool do_Mnoise,
												XFLOAT radius,
												XFLOAT radius_p,
												XFLOAT cosine_width	);

__global__ void cuda_kernel_translate2D(	XFLOAT * g_image_in,
											XFLOAT * g_image_out,
											int image_size,
											int xdim,
											int ydim, //not used
											int dx,
											int dy);

__global__ void cuda_kernel_selfTranslate2D(	XFLOAT * g_image_in,
												XFLOAT * g_image_out,
												int image_size,
												int xdim,
												int ydim, //not used
												int dx,
												int dy);

__global__ void cuda_kernel_powerClass2D(	CUDACOMPLEX * g_image,
											XFLOAT * g_spectrum,
											int image_size,
											int spectrum_size,
											int xdim,
											int ydim,
											int res_limit,
											XFLOAT * g_highres_Xi2);

__global__ void cuda_kernel_centerFFT_2D(XFLOAT *img_in,
										 int image_size,
										 int xdim,
										 int ydim,
										 int xshift,
										 int yshift);

__global__ void cuda_kernel_probRatio(  XFLOAT *d_Mccf,
										XFLOAT *d_Mpsi,
										XFLOAT *d_Maux,
										XFLOAT *d_Mmean,
										XFLOAT *d_Mstddev,
										int image_size,
										XFLOAT normfft,
										XFLOAT sum_ref_under_circ_mask,
										XFLOAT sum_ref2_under_circ_mask,
										XFLOAT expected_Pratio,
										int Npsi);

__global__ void cuda_kernel_rotateAndCtf( CUDACOMPLEX *d_Faux,
						  	  	  	  	  XFLOAT *d_ctf,
						  	  	  	  	  XFLOAT psi,
						  	  			  CudaProjectorKernel projector);

/*
 * Multiplies complex array A (in-place) by B, pixel-by-pixel, after conjugating A
 */
__global__ void cuda_kernel_convol_A(	 CUDACOMPLEX *d_A,
									 	 CUDACOMPLEX *d_B,
									 	 int image_size);

/*
 * Multiplies complex array A (in-place) by B, pixel-by-pixel, after conjugating A, writes to C
 */
__global__ void cuda_kernel_convol_A(	 CUDACOMPLEX *d_A,
									 	 CUDACOMPLEX *d_B,
									 	 CUDACOMPLEX *d_C,
									 	 int image_size);

/*
 * Multiplies many complex arrays A (in-place) by a single B, pixel-by-pixel, after conjugating A
 */
__global__ void cuda_kernel_batch_convol_A(	 CUDACOMPLEX *d_A,
									 	 	 CUDACOMPLEX *d_B,
									 	 	 int image_size);

/*
 * Multiplies complex array A (in-place) by B, pixel-by-pixel, after conjugating B
 */
__global__ void cuda_kernel_convol_B(	 CUDACOMPLEX *d_A,
									 	 CUDACOMPLEX *d_B,
									 	 int image_size);

/*
 * Multiplies complex array A (in-place) by B, pixel-by-pixel, after conjugating B, writes to C
 */
__global__ void cuda_kernel_convol_B(	 CUDACOMPLEX *d_A,
									 	 CUDACOMPLEX *d_B,
									 	 CUDACOMPLEX *d_C,
									 	 int image_size);
/*
 * Multiplies many complex arrays A (in-place) by a single one B, pixel-by-pixel, after conjugating B
 */
__global__ void cuda_kernel_batch_convol_B(	 CUDACOMPLEX *d_A,
									 	 	 CUDACOMPLEX *d_B,
									 	 	 int image_size);

/*
 * Multiplies scalar array A by a scalar S
 *
 *  OUT[i] = A[i]*S
 */
__global__ void cuda_kernel_multi( XFLOAT *A,
								   XFLOAT *OUT,
								   XFLOAT S,
		  	  	  	  	  	  	   int image_size);

/*
 * In place multiplies scalar array A by a scalar S
 *
 *  A[i] = A[i]*S
 */
__global__ void cuda_kernel_multi(
		XFLOAT *A,
		XFLOAT S,
		int image_size);
/*
 * Multiplies scalar array A by scalar array B and a scalar S, pixel-by-pixel
 *
 *  OUT[i] = A[i]*B[i]*S
 */
__global__ void cuda_kernel_multi( XFLOAT *A,
								   XFLOAT *B,
								   XFLOAT *OUT,
								   XFLOAT S,
		  	  	  	  	  	  	   int image_size);

__global__ void cuda_kernel_finalizeMstddev( XFLOAT *Mstddev,
											 XFLOAT *aux,
											 XFLOAT S,
											 int image_size);

/*
 * In place squares array in place
 *
 *  A[i] = A[i]*A[i]
 */
__global__ void cuda_kernel_square(
		XFLOAT *A,
		int image_size);

/*
 * Casts on device so we can copy_to_host directly into a multidimarray.
 */
template <typename T1, typename T2 >
__global__ void cuda_kernel_cast(
		T1 *IN,
		T2 *OUT,
		int size)
{
	int pixel = threadIdx.x + blockIdx.x*BLOCK_SIZE;
	if(pixel<size)
		OUT[pixel] = IN[pixel];
}

#endif /* CUDA_HELPER_KERNELS_CUH_ */
