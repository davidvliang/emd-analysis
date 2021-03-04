# emd-analysis
Fundamental understanding of EMD and formulas for periodicity and sensitivity are found in [1]. Algorithm and method found in [2]. Discussion of Mutual Information computation is briefly mentioned in [2] and detailed in [3]. 


## Updates
2021-02-24: ED approach omits important information. Will investigate a _k_-nearest neighbors (kNN) approach because it is a parameter-free estimator.

2021-03-03: Implement *k*-nearest neighbors to compute mutual information. Most efficient with k = 2 (?)


## Task Description (2021-02-10)

For the first four folders, 
1. Apply EMD on each of the 32 subcarriers
2. extract "EMD modes", AKA IMFs
3. reconstruct the respiratory signal by a sum of the subset of the EMD modes
4. analyze the periodicity and sensitivity of that subset.

## Algorithm for EMD Filtering

1. Apply EMD to obtain IMF's
2. Compute mutual info MI(k), k = 2, 3, .., n
3. Compute mutual information ratio MIR(k), k = 2, 3, .. n-1
4. final reconstruction K corresponds to largest MIR value
5. reconstruct respiratory component

## Computing Mutual Information (MI)

### Fast mutual information of two images or signals
The old method for computing MI is a published function based on the naive equidistant binning estimator (ED) method [3]. [Link to MATLAB documentation](https://www.mathworks.com/matlabcentral/fileexchange/13289-fast-mutual-information-of-two-images-or-signals). 

### *k* Nearest Neighbors (kNN) 
The current method for computing MI is a published function that uses kNN as discussed in [4]. This method is reportedly the "most stable and less affected by the method-specific parameter" [3].  [Link to GitHub respository](https://github.com/otoolej/mutual_info_kNN).

##Scripts

### by_sub_emd.m
EMD Filtering for single subcarrier. 


### by_trial_emd.m
EMD Filtering for single trial. Outputs figure of 32 subcarriers.


### batch_trial_emd.m
EMD Filtering for all 8 trials. Outputs 8 figures for 8 trials. Runs slowly.


## References

[1] [Continuous User Verification via Respiratory Biometrics](https://ieeexplore.ieee.org/document/9155258)

[2] [Tissue Artifact removal from Respiratory Signals Based on Empirical Mode Decomposition](https://www.researchgate.net/publication/234157872_Tissue_Artifact_Removal_from_Respiratory_Signals_Based_on_Empirical_Mode_Decomposition) 

[3] [Evaluation of Mutual Information Estimators for Time Series](https://www.researchgate.net/publication/45849000_Evaluation_of_Mutual_Information_Estimators_for_Time_Series)

[4] [Estimating Mutual Information](https://doi.org/10.1103/PhysRevE.69.066138)