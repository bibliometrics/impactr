# cite_gs----------------------
# Documentation
#' @title Extract additional citation metrics from Google Scholar
#' @description Extract additional citation metrics from Google Scholar
#' @param df Dataframe containing at least three columns: publictaion title ("title"), publication year ("year"), and DOI/PMID with each publication listed as a row.
#' @param scholar_id Google scholar ID number linking to records in the dataframe.
#' @param match_title_nchar Argument to specify how many characters the titles should be matched (default = 50). See "unmatch" output.
#' @import magrittr
#' @import dplyr
#' @import tibble
#' @import purrr
#' @importFrom tidyr pivot_longer
#' @importFrom stringr str_sub
#' @importFrom gcite gcite_user_info
#' @return Nested dataframe of: (1)."out_df" - Amended dataframe with additional total citations appended (2). "df_cite" - Dataframe of citations over time for google doc papers (3). "validation" - Dataframe of publications that could not be matched to a google scholar record (noscholar) or google scholar records that could not be matched to the dataframe (unmatched).
#' @export

# Function----------------
cite_gs <- function(df, gscholar_id, match_title_nchar = 50){
  "%ni%" <- Negate("%in%")
  gcite_data <- gcite::gcite_user_info(gscholar_id)$paper_df %>%
    tibble::as_tibble()

  cite_years <- suppressWarnings(names(gcite_data) %>%
                                   purrr::map_dbl(as.numeric) %>%
                                   na.omit() %>%
                                   as.vector())

  df_gs <- gcite_data %>%
    dplyr::mutate(year = as.numeric(stringr::str_sub(`publication date`, 1,4))) %>%
    dplyr::select(title, year, which(names(gcite_data) %in% cite_years)) %>%
    dplyr::mutate(title_match = gsub("[[:punct:]]", "",tolower(title))) %>%
    dplyr::mutate(title_match = stringr::str_sub(title_match, 1, match_title_nchar)) %>%
    dplyr::mutate_at(names(dplyr::select(., -title, -title_match, -year)),
                     function(x){ifelse(is.na(x)==T, 0, as.numeric(x))}) %>%
    dplyr::mutate(cite_gs = rowSums(dplyr::select(., -title, -title_match, -year))) %>%
    dplyr::select(-title,-year)

  df_out <- df %>%
    dplyr::mutate(title_match = gsub("[[:punct:]]", "",tolower(title))) %>%
    dplyr::mutate(title_match = substr(title_match, 1, match_title_nchar)) %>%
    dplyr::select(-dplyr::starts_with("cite_gs")) %>%
    dplyr::full_join(df_gs, by=c("title_match")) %>%
    dplyr::mutate(year = factor(year, levels=sort(unique(year))),
                  outcome = ifelse(is.na(pmid)==T&is.na(doi)==T, "unmatched",
                                   ifelse(is.na(cite_gs)==T, "noscholar", "matched")))

  validation <- df_out %>%
    dplyr::filter(outcome!="matched") %>%
    dplyr::select(outcome, pmid, doi, title_match)

  df_updated <- df_out %>%
    dplyr::filter(outcome!="unmatched") %>%
    dplyr::select(-title_match, -outcome, -which(names(.) %in% cite_years))

  df_cite <- df_out %>%
    dplyr::filter(outcome!="unmatched") %>%
    dplyr::select(pmid, doi,title, year, which(names(.) %in% cite_years)) %$%
    tidyr::pivot_longer(., cols = which(names(.) %in% cite_years),
                        names_to = "cite_year", values_to = "cite_n") %>%
    dplyr::group_by(title) %>%
    dplyr::mutate(cite_cumsum = cumsum(cite_n)) %>%
    dplyr::ungroup()

  out <- list("df" = df_updated, "year" = df_cite, "validation" = validation)

  return(out)}
