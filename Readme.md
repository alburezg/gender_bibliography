# Gender bias in academic bibliographies

This repository contains the code of a Shiny app developed for authors to evaluate the gender bias in their citation practices. 
It is an RStudio's Shiny app and relies on the [Crossref API](https://github.com/CrossRef/rest-api-doc). 

## Instructions for use

  - Copy and paste your bibliography in the text box to see how gender-bias or gender-balanced it is!
  - Do not include books, reports or theses. The tool currently only works with peer-reviewed and indexed papers.
  - The tool will look up each citation in a database and output the most likely match. Most matches are correct, but some noise if to be expected for older or lesser-known articles.
  - The gender of the authors is determined using U.S. Social Security Administration baby name data ([gender](https://www.r-project.org/nosvn/pandoc/gender.html) package in R). Unrecognised names are ignored.
  - Allow some time for the tool to retrieve the information from the API (up to a couple of minutes for long bibliographies).
  - If the tool doesn't load or if it cannot be reached (e.g. Error 504), please wait five minutes to reload the page. 

**This tool relies on the kindness of the [Crossref API](https://github.com/CrossRef/rest-api-doc). Don't abuse it!**

Click (here)[http://alburez.me/2018-06-01-Gender-in-References/] to deploy the app.