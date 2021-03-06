% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/extract_pmid.R
\name{extract_pmid}
\alias{extract_pmid}
\title{Extract publication data using RISmed / pmid}
\usage{
extract_pmid(pmid, get_auth = TRUE, get_altmetric = TRUE,
  get_impact = TRUE)
}
\arguments{
\item{pmid}{Vector of unique PubMed identifier numbers (PMID)}

\item{get_auth}{Extract authorship data (default = TRUE)}

\item{get_altmetric}{Extract overall altmetric score data (default = TRUE)}

\item{get_impact}{Extract journal impact factor and metrics (default = TRUE)}
}
\value{
Dataframe of essential publication data
}
\description{
Extract publication data using RISmed / pmid
}
