**Transform KQL**
Transform KQL can be dificult at times as it can require some trial and error along with waiting for everything to be written down properly.  These repo is created to assist with transformation, lessons learned and troubleshooting steps.  While a majority of this data is available on Microsoft documentation sites the goal is to consolidate as much as posssible to reduce headaches and help to speedup adoption of AMA and Sentinel. 


Know your limits - https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/data-collection-transformations-structure#supported-kql-features


Types of transform options 
* Table Transformation
* Remove sensitive data
  *  Enrich data with more or calculated information
  * Obfuscate sensitive information
  * Send to an alternate table
*  Enrich data with more or calculated information
   * Add business-specific information
   * Add a column with more information
* Reduce data costs
  * Remove entire rows
  * Remove a column from each row
  * Parse important data from a column
  * Send certain rows to lower cost storage
