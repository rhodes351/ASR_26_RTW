Replication materials for "The Right to Work and Economic Dynamism in US Counties, 1946-2019"

In these files, we provide the County Business Pattern data and Stata code used in our analyses. The core data files needed to replicate the analyses include:

-cbpco_panel - County Business Patterns data, 1946-2016. The underlying source for these data come from Eckert et al. (2020, 2022), IPUMS NHGIS (Schroeder et al. 2025), and the US Census Bureau. Files in the "create_cbpco_panel" provide raw data and Stata code used to construct this panel.

-countylistdube - List of border counties from Dube et al. (2010)

-pcd_data01-merge_controls2 - Dataset including RTW indicators and measures of state union density (Farber et al. 2021) and state policy leaning (Caughey and Warshaw 2016)

-CountyPopulationDecennialEstimates - Dataset including county-level population estimates from IPUMS NHGIS (Schroeder et al. 2025)

-bea_statevars - Dataset including Bureau of Economic Analysis state tax policy data (Slattery 2025)

-export_ind_disagg - CSV file containing tax policy data from the Upjohn Institute (Bartik 2017)

-bds_cty_data - A .dta file including county-level measures from the US Census's Business Dynamics Statistics Data

-epi-productivity - A .dta file including state-level data on labor productivity from the Economic Policy Institute

In addition, we provide the Stata (Stata/SE 19.0) code that we used to conduct the analyses:

-MAIN_TEXT_ANALYSES_2025_12_19 - A .do file containing most of the main text and all of the supplemental appendix analyses

-pcd_incentives01-upjohn - A .do file with code to generate the trends shown in Figure 5 (top and middle row)

-pcd_incentives02-bea - A .do file with code to generate the trends shown in Figure 5 (bottom row)

-pcd-epi-productivity - A .do file with code to analyze state-level labor productivity (Table S3 in the Online Supplement)

The do-file used to create the pooled CBP analysis panel dataset can be found in the "Data/create_cbpco_panel" folder.

For questions about these files, please contact Alec Rhodes (aprhodes@purdue.edu)

References

Bartik, Timothy. 2017. "A New Panel Database on Business Incentives for Economic
Development Offered by State and Local Governments in the United States." Prepared for
the Pew Charitable Trusts. https://research.upjohn.org/reports/225/

Caughey, Devin and Christopher Warshaw. 2016. "The Dynamics of State Policy Liberalism, 1936-2014." American Journal of Political Science 60(4):899-913.

Dube, Arindrajit, T. William Lester, and Michael Reich. 2010. "Minimum Wage Effects Across
State Borders: Estimates Using Contiguous Counties." The Review of Economics and
Statistics 92(4):945-964.

Eckert, Fabian, Teresa C. Fort, Peter K. Schott, and Natalie J. Yang. 2020. "Imputing Missing Values in the US Census Bureau's County Business Patterns." NBER Working Paper 26632. Cambridge, MA: National Bureau of Economic Research.

Eckert, Fabian, Ka-leung Lam, Atif R. Mian, Karsten Muller, Rafael Schwalb, and Amir Sufi. 2022. "The Early County Business Patten Files: 1946-1974." NBER Working Paper 30578. Cambridge, MA: National Bureau of Economic Research.

Farber, Henry S., Daniel Herbst, Ilyana Kuziemko, and Suresh Naidu. 2021. "Unions and
Inequality over the Twentieth Century: New Evidence from Survey Data." The Quarterly
Journal of Economics 136(3):1325-1385.

Schroeder, Jonathan, David Van Riper, Steven Manson, Katherine Knowles, Tracy Kugler, Finn Roberts, and Steven Ruggles. IPUMS National Historical Geographic Information System: Version 20.0 [dataset]. Minneapolis, MN: IPUMS. 2025. http://doi.org/10.18128/D050.V20.0.

Slattery, Cailin. 2025. "Bidding for Firms: Subsidy Competition in the United States." Journal of Political Economy 133(8):2371-2692.
