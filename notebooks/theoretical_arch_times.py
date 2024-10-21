DMA_config = 100
signal_depth = 5121
dwc_pipeline_depth = 10
fec_pipeline_depth = 10

n_signals = 1
paralell_cores = 4.0

first_arch  = n_signals*(DMA_config + signal_depth + \
                         dwc_pipeline_depth*4 + \
                         fec_pipeline_depth*1)
second_arch = (n_signals/paralell_cores)* \
             ((3*DMA_config + signal_depth + dwc_pipeline_depth) + \
              (3*DMA_config + signal_depth/2 + 0*dwc_pipeline_depth) + \
              (3*DMA_config + signal_depth/4.0 + 0*dwc_pipeline_depth) + \
              (3*DMA_config + signal_depth/8.0 + 0*dwc_pipeline_depth))
third_arch  = (n_signals/paralell_cores)* \
              ((2*DMA_config + signal_depth     + dwc_pipeline_depth + fec_pipeline_depth) + \
               (2*DMA_config + signal_depth/2.0 + dwc_pipeline_depth + 0*fec_pipeline_depth) + \
               (2*DMA_config + signal_depth/4.0 + dwc_pipeline_depth + 0*fec_pipeline_depth) + \
               (2*DMA_config + signal_depth/8.0 + dwc_pipeline_depth + 0*fec_pipeline_depth))

print(first_arch)
print(second_arch)
print(third_arch)