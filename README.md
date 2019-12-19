# FilteredBackprojection

I wrote two versions (MATLAB & C++) to implement the Filtered Backprojection Algorithm

## 1. MATLAB
This is the overview of GUI. There are 5 modules:![](https://github.com/charlotte12l/FilteredBackprojection/blob/master/GUI_overview.png) 

### 1.1 Read Image
- Click "Shepp Logan" to open a standard Shepp Logan model
- Click "other image" to read other pictures from the computer, which will be automatically converted to single channel gray-scale image.

### 1.2 Projection
- After reading the picture, we should use the projection module for radon transformation.  
- First, enter the number of projection angles at the projection number.      
- After that, click "projection", the software executes the projection program, and displays the projection process and results in a white box.

### 1.3 Filtering
- After the projection, enter the filter module and choose different filters to process the projection function.
- After selecting the filter, click "Filtering" to obtain the filtered projection function image in the white box.

### 1.4 Reconstruction
- After filtering, click "Reconstruction" to realize reconstruction

### 1.5 Reconstruction Evaluation
- After reconstruction, click "reconstruction evaluation" to calculate and display the normalized mean square distance criterion d and normalized average absolute distance criterion r.

### Result
This is the result of using the GUI for Shepp Logan.![](https://github.com/charlotte12l/FilteredBackprojection/blob/master/GUI_sample.png)


## 2. C++
C++ version is a relatively simple one due to the limitation of time.
Here is the result of C++ FBP for Shepp Logan, it is not as good as the MATLAB version.

![](https://github.com/charlotte12l/FilteredBackprojection/blob/master/cpp_result.png)
