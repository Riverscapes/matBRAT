<link rel="shortcut icon" type="image/x-icon" href="favicon.ico">

[![BRAT_Banner_Web]({{ site.baseurl }}/assets/Images//BRAT_Banner_Web.png)]({{ site.baseurl }})

*BRAT* is the [Beaver Restoration Assessment Tool](http://brat.riverscapes.xyz). The model is a stream network model, that is geared towards building appropriate expectation management with respect to the dam building activities of beaver. The model is intended to help resource managers plan and prioritize where beaver may build dams naturally, what the capacity of the streamscape is to support their dam buliding activity, predict where the potential for human-beaver conflicts may arise, and highlight where and where-not beaver make sense as a conservation or restoration tool.

Versions 1.0 through 2.03 consisted of a set of manual ArcGIS geoprocessing steps and workflow, and the model itself was run through a series of Matlab scripts (provided [here](https://github.com/Riverscapes/matBRAT/releases/latest)). This version of the code is no longer maintained or supported as it has been superseded by an ArcGIS toolbox version of the model ([pyBRAT](https://github.com/Riverscapes/pyBRAT)) that uses ArcPy. [pyBRAT](http://brat.riverscapes.xyz) started at version 3.0. Fuller documentation on the background of BRAT, as well as various [BRAT data products](http://brat.riverscapes.xyz/BRATData/BRATDatahome) are available on the main BRAT website: [http://brat.riverscapes.xyz](http://brat.riverscapes.xyz)   

For those users who prefer the Matlab version, these pages are maintained as a reference. Full documentation on how to implement the geoprocessing and use this source code is available below.

### What is this repository for?

This repository is for the BRAT Matlab scripts.

- Version [2.0.3](https://github.com/Riverscapes/matBRAT/releases/tag/v2.03)

### Documentation for the Beaver Restoration Assessment Tool (matBRAT) 

- [1. Input Data Capture]({{ site.baseurl }}/matBRAT/1-InputData)
- [2. Stream Network Geoprocessing]({{ site.baseurl }}/matBRAT/2-StreamNetwork)
- [3. Vegetation Classification: Dam Building Material Preferences]({{ site.baseurl }}/matBRAT/3-VegetationClassification)
- [4. Calculating Upstream Drainage Area]({{ site.baseurl }}/matBRAT/4-CalcUpstream)
- [5. Potential Conflict Layer Processing]({{ site.baseurl }}/matBRAT/5-PotentialConflict)
- [6. Transfering Attributes onto the Stream Network]({{ site.baseurl }}/matBRAT/6-TransferingAttributes)
- [7. Formatting BRAT Input Data]({{ site.baseurl }}/matBRAT/7-FormattingBRATInputData)
- [8. Running BRAT Model]({{ site.baseurl }}/matBRAT/8-RunningBRATModel)
- [9. Finalizing BRAT Outputs]({{ site.baseurl }}/matBRAT/9-FinalizingBRATOutputs)

### Workshop
One [workshop]({{ site.baseurl }}/Workshops) specifically on matBRAT, was run for Wilberforce and the Grand Canyon Trust in April 2013. 
[2013 BRAT Workshop]({{ site.baseurl }}/Workshops)

