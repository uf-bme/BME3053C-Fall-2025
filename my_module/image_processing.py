import numpy as np
from typing import Optional


def _gaussian_kernel1d(sigma: float) -> np.ndarray:
    """Create a 1D Gaussian kernel with given sigma (normalized).

    Kernel radius is ceil(3*sigma). For sigma <= 0 returns [1.0].
    """
    if sigma <= 0 or np.isclose(sigma, 0.0):
        return np.array([1.0], dtype=np.float32)
    radius = int(np.ceil(3 * sigma))
    x = np.arange(-radius, radius + 1, dtype=np.float32)
    kernel = np.exp(-(x * x) / (2.0 * sigma * sigma)).astype(np.float32)
    s = kernel.sum()
    if s == 0:
        return np.array([1.0], dtype=np.float32)
    kernel /= s
    return kernel


def _apply_separable_conv2d(img2d: np.ndarray, kernel: np.ndarray) -> np.ndarray:
    """Apply separable 1D convolution (row then column) to a 2D array.

    Uses np.convolve with mode='same' along each axis.
    """
    # Convolve each row (axis=1)
    tmp = np.apply_along_axis(lambda m: np.convolve(m, kernel, mode="same"), axis=1, arr=img2d)
    # Then convolve each column (axis=0)
    out = np.apply_along_axis(lambda m: np.convolve(m, kernel, mode="same"), axis=0, arr=tmp)
    return out


def process_image(
    img: np.ndarray,
    normalize: bool = True,
    filter_sigma: Optional[float] = 1.0,
) -> np.ndarray:
    """Process a medical image array with normalization and optional Gaussian filtering.

    Parameters
    - img: numpy.ndarray
        2D (H, W) grayscale image or 3D (H, W, C) image with channels last.
    - normalize: bool
        If True, scale image values to the range [0, 1] based on min/max.
    - filter_sigma: float or None
        Standard deviation for Gaussian blur. If <= 0 or None, no blur is applied.

    Returns
    - processed: numpy.ndarray
        Array of type float32 with the same shape as input (values in [0,1] if normalized).

    Raises
    - TypeError if img is not a numpy.ndarray
    - ValueError for invalid shapes or negative sigma

    Example
    >>> import numpy as np
    >>> from my_module.image_processing import process_image
    >>> a = np.random.randint(0, 256, size=(128, 128), dtype=np.uint8)
    >>> b = process_image(a, normalize=True, filter_sigma=1.5)
    """
    if not isinstance(img, np.ndarray):
        raise TypeError("img must be a numpy.ndarray")

    if img.ndim not in (2, 3):
        raise ValueError("img must be 2D (H,W) or 3D (H,W,C) with channels last")

    if filter_sigma is None:
        filter_sigma = 0.0

    if filter_sigma < 0:
        raise ValueError("filter_sigma must be non-negative")

    # Work in float32 for numeric stability
    img_f = img.astype(np.float32, copy=True)

    # Normalize to [0,1]
    if normalize:
        minv = float(np.nanmin(img_f))
        maxv = float(np.nanmax(img_f))
        if np.isfinite(minv) and np.isfinite(maxv) and (maxv > minv):
            img_f = (img_f - minv) / (maxv - minv)
        else:
            # Degenerate case (constant image)
            img_f = np.zeros_like(img_f, dtype=np.float32)

    # Apply Gaussian filtering if requested
    if filter_sigma and (filter_sigma > 0):
        kernel = _gaussian_kernel1d(float(filter_sigma))
        if img_f.ndim == 2:
            img_f = _apply_separable_conv2d(img_f, kernel)
        else:
            # Apply per-channel
            out = np.empty_like(img_f)
            for c in range(img_f.shape[2]):
                out[:, :, c] = _apply_separable_conv2d(img_f[:, :, c], kernel)
            img_f = out

    # Ensure float32 output
    return img_f.astype(np.float32)
