library(shiny)
library(shinyjs)
library(shinyBS)
library(bslib)
library(htmltools)
library(shinyscreenshot)
library(fontawesome)
library(tidyverse)
library(rstatix)
library(knitr)
library(compositions)
library(car)
library(correlation)
library(MVN)
library(performance)
library(modelbased)
library(patchwork)
library(see)
library(bestNormalize)
library(DHARMa)
library(lmerTest)
library(MASS)
library(nnet)
library(broom)
library(broom.mixed)
library(DT)
library(sjPlot)
source("https://gist.githubusercontent.com/benmarwick/2a1bb0133ff568cbe28d/raw/fb53bd97121f7f9ce947837ef1a4c65a73bffb3f/geom_flat_violin.R")

# ----- UI -----
ui <- navbarPage(
  title = HTML('
  <span style="font-size: 25px; font-weight: 700; color: #2c3e50; font-family: \'Segoe UI\', sans-serif;">
    <i class="fas fa-chart-simple" style="color: #3A9BB2; margin-right: 8px;"></i>
    <span style="color: #3A9BB2;">Assump</span><span style="color: #E3A599;">Sure</span>
  </span>
'),

  theme = bslib::bs_theme(
    version = 5,
    bootswatch = "minty",  
    primary = "#2c3e50",    
    navbar_bg = "#2c3e50",  
    navbar_fg = "white",    
    base_font = bslib::font_google("Open Sans"),
    heading_font = bslib::font_google("Open Sans"),
    nav_link_padding_x = "1.5rem",  
    nav_link_font_weight = 500
  ),
  header = tagList(
    useShinyjs(),
    tags$head(
      htmltools::htmlDependency("font-awesome", "6.1.1",
                                src = c(href = "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.1.1/"),
                                stylesheet = "css/all.min.css"
      )
    ),
    tags$head(
      tags$style(HTML("
        .tooltip-inner {
          max-width: 350px !important;
          min-width: 220px !important;
          white-space: pre-line !important;
          font-size: 15px;
          text-align: left;
          word-break: break-word;
        }
        .btn-primary {
          background-color: #9EC2D1 !important;
          border-color: black !important;
          color: black !important;
        }
        .btn-success {
          background-color: #F2E099 !important;
          border-color: black !important;
          color: black !important;
        }
        .btn-warning {
          background-color: #3A9BB2 !important;
          border-color: black !important;
          color: black !important;
        }
        .btn-info {
          background-color: #E3A599 !important;
          border-color: black !important;
          color: black !important;
        }
      "))
    ),
    # Check box
    tags$head(
      tags$style(HTML("
      input[type=\"checkbox\"] {
        border: 1px solid black !important;
      }
    "))
    ),
    # Browse button
    tags$head(
      tags$style(HTML("
      .shiny-input-container .btn-default {
        border: 1px solid black !important;
        background-color: #2c3e50 !important;
        color: white !important;
        padding: 8px 16px !important;
        font-size: 14px !important;
        border-radius: 5px !important;
      }
    "))
    ),
    # Download buttons
    tags$head(
      tags$style(HTML("
      .shiny-download-link.btn {
        border: 1px solid black !important;
        background-color: white !important;
        color: black !important;
        padding: 8px 16px !important;
        font-size: 16px !important;
        border-radius: 5px !important;
      }
      /* Optional: on hover */
      .shiny-download-link.btn:hover {
        background-color: #f2f2f2 !important;
        color: black !important;
      }
    "))
    ),
    # Run Selected option buttons
    tags$head(
      tags$style(HTML("
      #run_posthoc.btn {
        border: 1px solid black !important;
        background-color: white !important;
        font-weight: 600;
        color: black !important;
        padding: 8px 16px !important;
        font-size: 16px !important;
        border-radius: 5px !important;
        transition: all 0.2s ease-in-out;
      }
      #run_posthoc.btn:hover {
        background-color: #f2f2f2 !important;
        color: black !important;
      }
    "))
    ),
    # Plot Boxplot
    tags$head(
      tags$style(HTML("
      .btn-plot {
        background-color: white !important;
        border: 1px solid black !important;
        color: black !important;
        font-weight: 600;
        padding: 8px 16px;
        border-radius: 5px;
        transition: all 0.2s ease-in-out;
      }
      .btn-plot:hover {
        background-color: #e8f4f7 !important;
        color: #2c3e50 !important;
      }
    "))
    ),
    tags$head(
      tags$script(HTML("
      document.addEventListener('DOMContentLoaded', function () {
        var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle=\"tooltip\"]'))
        var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
          return new bootstrap.Tooltip(tooltipTriggerEl)
        })
      });
    "))
    ),
    tags$head(
      tags$script(HTML("
      Shiny.addCustomMessageHandler('reinit-tooltips', function(message) {
        var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle=\"tooltip\"]'));
        tooltipTriggerList.map(function(el) {
          return new bootstrap.Tooltip(el);
        });
      });
      document.addEventListener('DOMContentLoaded', function () {
        var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle=\"tooltip\"]'));
        tooltipTriggerList.map(function(el) {
          return new bootstrap.Tooltip(el);
        });
      });
    "))
    ),
    tags$head(
      tags$style(HTML("
      /* Custom Tab Colors */
      .nav-tabs > li > a[data-value='Dependent Variable Normality'] {
        background-color: #3A9BB2 !important;
        color: black !important;
        border-color: black !important;
      }
      .nav-tabs > li > a[data-value='Test Result'] {
        background-color: #F2E099 !important;
        color: black !important;
        border-color: black !important;
      }
      .nav-tabs > li > a[data-value='Assumptions'] {
        background-color: #9EC2D1 !important;
        color: black !important;
        border-color: black !important;
      }
      .nav-tabs > li > a[data-value='Effect Plot'] {
        background-color: #E3A599 !important;
        color: black !important;
        border-color: black !important;
      }
      /* Highlight Active Tab with Border */
      .nav-tabs .nav-item.show .nav-link,
      .nav-tabs .nav-link.active {
      border-top: 3px solid #2c3e50 !important; /* Same as your navbar color */}
    "))
    ),
    tags$head(
      tags$style(HTML("
        /* Center-align the entire navbar */
        .navbar {
          display: flex;
          justify-content: center; /* Centers the content horizontally */
          align-items: center; /* Vertically centers the content */
        }
        /* Adjust spacing between main tabs */
        .navbar-nav .nav-item {
          margin-right: 15px !important; /* Space between main tabs */
        }
        /* Remove left margin from the first tab */
        .navbar-nav .nav-item:first-child {
          margin-left: -80px !important; /* Adjust distance between app name and Welcome */
        }
        .navbar-brand {
        margin-right: 200px !important; /* Adjust as needed */
        }
      "))
    ),
    # Hide download buttons (Continuous)
    tags$head(
      tags$script(HTML("
    function screenshotWithoutDownloadBtns() {
      // Hide all elements with class 'no-print'
      var btns = document.getElementsByClassName('no-print');
      for(var i=0;i<btns.length;i++){ btns[i].style.display='none'; }
      // Wait 250ms, then trigger shiny's screenshot, then restore
      setTimeout(function() {
        Shiny.setInputValue('start_screenshot', new Date().getTime());
        setTimeout(function() {
          for(var i=0;i<btns.length;i++){ btns[i].style.display=''; }
        }, 750);
      }, 250);
    }
  "))
    ),
    # Hide download buttons (Correlation)
    tags$head(
      tags$script(HTML("
function corScreenshotWithoutScatterBtn() {
  var btns = document.getElementsByClassName('cor-hide-in-screenshot');
  for(var i=0; i<btns.length; i++) { btns[i].style.display='none'; }
  setTimeout(function() {
    Shiny.setInputValue('cor_start_screenshot', new Date().getTime());
    setTimeout(function() {
      for(var i=0; i<btns.length; i++) { btns[i].style.display=''; }
    }, 500); // restore after 0.5s
  }, 200); // trigger screenshot after 0.2s
}
  "))
    )
    ),

  
  # Navigation panels start here
  tabPanel(
    title = tagList(icon("home"), "Welcome"),
    bslib::page_fillable(
      fillable = TRUE,
      padding = 3,
      style = "background-color: #f8f9fc; font-family: 'Segoe UI', sans-serif;",
      # Main Content Card
      div(
        style = "margin-top: 20px; width: 98vw; padding: 1rem;",
        div(
          class = "card shadow-lg p-4",
          style = "border-radius: 20px; background-color: white; box-shadow: 0 6px 20px rgba(0,0,0,0.05);",
          h2(strong("Guiding rigorous statistical practice from start to finish"),
             style = "text-align: center; color: #2c3e50; margin-bottom: 30px;"),
          # Three-column feature cards
          fluidRow(
            column(
              4,
              div(
                style = "text-align: center; padding: 20px; border-radius: 15px; background: #e8f4f7; transition: transform 0.2s; box-shadow: 0 4px 10px rgba(0,0,0,0.05); cursor: pointer; height: 200px;",
                onmouseover = "this.style.transform='scale(1.03)';",
                onmouseout = "this.style.transform='scale(1)';",
                icon("clipboard-check", class = "fa-3x", style = "color: #3A9BB2; margin-bottom: 15px;"),
                h5("Assumption Clarity", style = "font-weight: 600; color: #2c3e50;"),
                p("Automatically validate and interpret statistical assumptions to ensure accurate and reliable test results.",
                  style = "color: #666;")
              )
            ),
            column(
              4,
              div(
                style = "text-align: center; padding: 20px; border-radius: 15px; background: #f0f7fb; transition: transform 0.2s; box-shadow: 0 4px 10px rgba(0,0,0,0.05); cursor: pointer; height: 200px;",
                onmouseover = "this.style.transform='scale(1.03)';",
                onmouseout = "this.style.transform='scale(1)';",
                icon("file-lines", class = "fa-3x", style = "color: #3D9DB3; margin-bottom: 15px;"),
                h5("Report-Ready Outputs", style = "font-weight: 600; color: #2c3e50;"),
                p("Download polished results and assumption plots to support transparent reporting and justify test selection.", style = "color: #666;")
              )
            ),
            column(
              4,
              div(
                style = "text-align: center; padding: 20px; border-radius: 15px; background: #fdf7f4; transition: transform 0.2s; box-shadow: 0 4px 10px rgba(0,0,0,0.05); cursor: pointer; height: 200px;",
                onmouseover = "this.style.transform='scale(1.03)';",
                onmouseout = "this.style.transform='scale(1)';",
                icon("shapes", class = "fa-3x", style = "color: #E3A599; margin-bottom: 15px;"),
                h5("Broad Statistical Support", style = "font-weight: 600; color: #2c3e50;"),
                p("From t-tests to mixed models, AssumpSure covers many statistical tools used in research.",
                  style = "color: #666;")
              )
            )
          ),
          hr(style = "margin: 30px 0;"),
          div(
            style = "background: linear-gradient(to right, #eaf4f9, #f5fbff); padding: 20px; border-radius: 15px;",
            h4(icon("info-circle", style = "margin-right: 8px;"), "Why AssumpSure?", style = "font-weight: 600; color: #2c3e50; display: inline-block;"),
            p("Many researchers misuse statistical tests by overlooking or misinterpreting key assumptions, which can lead to invalid conclusions. AssumpSure guides users through assumption checks to ensure analyses are statistically sound, transparent, and ready for publication.", style = "color: #444; margin-top: 10px;
              font-size: 17px;")
          ),
          hr(style = "margin: 30px 0;"),
          h4(icon("users", style = "margin-right: 8px;"), "Who Can Use This App",
             style = "font-weight: 600; color: #2c3e50;"),
          tags$ul(
            style = "list-style: none; padding-left: 0;",
            tags$li(
              icon("circle-check", style = "color: #3A9BB2; margin-right: 8px;"),
              "Researchers with limited statistical background who need help selecting the correct statistical test."
            ),
            tags$li(
              icon("circle-check", style = "color: #3A9BB2; margin-right: 8px;"),
              "Users with no programming experience who want a code-free analysis workflow."
            ),
            tags$li(
              icon("circle-check", style = "color: #3A9BB2; margin-right: 8px;"),
              "Anyone unsure whether assumptions are met before running statistical tests."
            ),
            tags$li(
              icon("circle-check", style = "color: #3A9BB2; margin-right: 8px;"),
              "Students, clinicians, and early-career scientists seeking fast, dependable analysis."
            ),
            tags$li(
              icon("circle-check", style = "color: #3A9BB2; margin-right: 8px;"),
              "Teams that need clear, publication-ready plots and summaries without manual formatting"
            )
          ),
          div(
            style = "text-align: center; margin-top: 30px; font-style: italic; color: #666; font-size: 0.95em;",
            "Let science speak with statistical integrity."
          )
        )
      )
    )
  ),
 
  tabPanel("Continuous Data Tests",
           fluidPage(
             useShinyjs(),
             tags$head(
               tags$style(HTML(
                 '
    .nav-tabs>li>a[data-value="Assumption Tests"]
    { background-color: #9EC2D1 !important; color: #333 !important; border-color: black !important;}
    .nav-tabs>li>a[data-value="Test Results"]
    { background-color: #F2E099 !important; color: #333 !important; border-color: black !important;}
    .nav-tabs > li + li {
      margin-left: 5px !important;
    }

    @media print {
      .no-print {
        display: none !important;
      }
    }
    '
               ))
             ),
             sidebarLayout(
               sidebarPanel(
                 fileInput("file", "Upload CSV File", accept = ".csv"),
                 uiOutput("timepoint_ui"),
                 selectInput("test_type", "Select Statistical Test:",
                             choices = c(
                               "Choose Test" = "",
                               "Independent T-test" = "independent_ttest",
                               "Paired T-test" = "dependent_ttest",
                               "Mann-Whitney U test" = "mannwhitney",
                               "Wilcoxon Signed-Rank Test" = "wilcoxon_signed",
                               "One-way ANOVA" = "anova",
                               "Kruskal–Wallis Test" = "kruskal"
                             )),
                 uiOutput("column_selectors"),
                 actionButton("check_assumptions", "Check Assumptions", class = "btn-primary"),
                 actionButton("run_test", "Run Test", class = "btn-success"),
               ),
               mainPanel(
                 tabsetPanel(
                   id = "cont_tabs",
                   #tabPanel("Assumption Tests", uiOutput("assumption_content")),
                   tabPanel("Assumption Tests",
                            uiOutput("assumption_render"),
                            tags$div(style = "margin-top: 10px;"),
                            uiOutput("show_screenshot_btn"),
                            div(id = "report_content",
                                uiOutput("assumption_content")),
                           ),
                   tabPanel("Test Results",
                            uiOutput("test_result_with_square"),
                            uiOutput("posthoc_ui"),
                            uiOutput("posthoc_result_ui"),
                            br(),
                            actionButton("plot_boxplot", "Plot Boxplot", class = "btn-plot"),
                            plotOutput("boxplot"),
                            downloadButton("download_boxplot", "Download Boxplot")
                   )
                 )
               )
             )
           )
  ),

  tabPanel("Fisher & Chi-square",
           fluidPage(
             sidebarLayout(
               sidebarPanel(
                 fileInput("file_fisher", "Upload CSV File", accept = ".csv"),
                 uiOutput("fisher_timepoint_ui"),
                 selectInput("cat1", "Select first categorical variable:",
                             choices = c("Select variable" = ""), selected = ""),
                 selectInput("cat2", "Select second categorical variable:",
                             choices = c("Select variable" = ""), selected = ""),
                 selectInput("test_type_fisher", "Choose test:",
                             choices = c("Choose Test" = "",
                                         "Chi-square test" = "chisq",
                                         "Fisher’s exact test" = "fisher"),
                             selected = ""),
                 actionButton("run_fisher", "Run Test", class = "btn-success"),
                 actionButton("plot_fisher", "Plot", class = "btn-primary")
               ),
               mainPanel(
                 verbatimTextOutput("fisher_chisq_result"),
                 uiOutput("fisher_chisq_square"),
                 br(),
                 uiOutput("posthoc_method_ui"),
                 verbatimTextOutput("posthoc_result_fisher"),
                 plotOutput("fisher_plot"),
                 downloadButton("download_fisher_plot", "Download Plot", ),
                 uiOutput("chi_fisher_warning")
               )
             )
           )
  ),

  navbarMenu("Regression Models",
             tabPanel("Linear Model (LM)",
                      fluidPage(
                        titlePanel("Linear Model (LM)"),
                        sidebarLayout(
                          sidebarPanel(
                            fileInput("lm_file", "Upload CSV File", accept = ".csv"),
                            uiOutput("lm_dep_ui"),
                            uiOutput("lm_indep_ui"),
                            uiOutput("lm_interact_ui"),
                            selectInput("lm_transform",
                                        tagList(
                                          "Transform dependent variable (optional):",
                                          tags$span(
                                            icon("info-circle", class = "fa-solid"),
                                            `data-bs-toggle` = "tooltip",
                                            `data-bs-placement` = "right",
                                            title = "Tip: If the dependent variable is highly skewed or not normally distributed, please apply a transformation before running the test. Use Log or Box-Cox for values > 0. Use Yeo-Johnson or Inverse Normal for variables with zeros or negatives. Always inspect the histogram before and after transformation."
                                          )),
                                        choices = c(
                                          "None" = "none",
                                          "Log" = "log",
                                          "Yeo-Johnson" = "yeojohnson",
                                          "Box-Cox" = "boxcox",
                                          "Inverse Normal" = "invnorm"
                                        ),
                                        selected = "none"
                            ),
                            actionButton("lm_check_norm", "Check Dependent Variable Normality",
                                         class = "btn-warning"),
                            tags$div(style = "margin-top: 5px;"),
                            actionButton("lm_run", "Run LM", class = "btn-success"),
                            tags$div(style = "margin-top: 5px;"),
                            actionButton("lm_check", "Check Assumptions", class = "btn-primary"),
                            tags$div(style = "margin-top: 5px;"),
                            actionButton("lm_plot", "Plot Effects", class = "btn-info")
                          ),
                          mainPanel(
                            tabsetPanel(
                              id = "lm_tabs",
                              tabPanel("Dependent Variable Normality",
                                       fluidRow(column(6,
                                                plotOutput("lm_hist_before"),
                                                downloadButton("download_hist_before", "Download Before")),
                                                column(6,
                                                       conditionalPanel(
                                                         condition = "input.lm_transform != 'none'",
                                                         plotOutput("lm_hist_after"),
                                                         downloadButton("download_hist_after", "Download After")
                                                       )))),
                              tabPanel("Test Result", verbatimTextOutput("lm_result")),
                              tabPanel("Assumptions",
                                       plotOutput("lm_assump", height = "700px"),
                                       br(),
                                       downloadButton("lm_download_assump", "Download Assumption Plot")),
                              tabPanel("Effect Plot",
                                       plotOutput("lm_effect", height = "550px", width = "600px"),
                                       br(),
                                       downloadButton("lm_download_effect", "Download Effect Plot"))
                            )
                          )
                        )
                      )
             ),
             tabPanel("Linear Mixed Model (LMM)",
                      fluidPage(
                        titlePanel("Linear Mixed Model (LMM)"),
                        sidebarLayout(
                          sidebarPanel(
                            fileInput("lmm_file", "Upload CSV File", accept = ".csv"),
                            uiOutput("lmm_dep_ui"),
                            uiOutput("lmm_indep_ui"),
                            uiOutput("lmm_interact_ui"),
                            selectizeInput(
                              "lmm_re",
                              label = tagList(
                                "Select random effect grouping variable(s):",
                                tags$span(
                                  icon("info-circle", class = "fa-solid"),
                                  `data-bs-toggle` = "tooltip",
                                  `data-bs-placement` = "right",
                                  title = "How to choose random effects: Use a random effect for hierarchical or grouped data (e.g., patient ID). If a grouping variable has many levels (usually more than 5), treat it as a random effect. With fewer levels, it is safer to include them as fixed effects (an independent variable). For nested data structures (e.g., students within classes within schools), include all relevant grouping variables as random effects to account for within-group correlations. Always ensure your choice reflects the study design and model assumptions.",
                                  style = "margin-left: 8px; color: #2c3e50; font-size:16px; cursor: pointer;"
                                )
                              ),
                              choices = c("Select variable" = ""),
                              selected = "",
                              multiple = TRUE,
                              options = list(placeholder = 'Select variable')
                            ),
                            tags$div(
                              style = "display: flex; align-items: center;",
                              tags$label("Transform dependent variable (optional):", `for` = "lmm_transform"),
                              tags$span(
                                icon("info-circle", class = "fa-solid"),
                                `data-bs-toggle` = "tooltip",
                                `data-bs-placement` = "right",
                                title = "Tip: If the dependent variable is highly skewed or not normally distributed, please apply a transformation before running the test. Use Log or Box-Cox for values > 0. Use Yeo-Johnson or Inverse Normal for variables with zeros or negatives. Always inspect the histogram before and after transformation.",
                                style = "margin-left: 8px; color: #2c3e50; font-size:16px; cursor: pointer;"
                              )),
                            selectInput(
                              "lmm_transform",
                              label = NULL,
                              choices = c(
                                "None" = "none",
                                "Log" = "log",
                                "Yeo-Johnson" = "yeojohnson",
                                "Box-Cox" = "boxcox",
                                "Inverse Normal" = "invnorm"
                              ),
                              selected = "none"
                            ),
                            actionButton("lmm_check_norm", "Check Dependent Variable Normality",
                                         class = "btn-warning"),
                            tags$div(style = "margin-top: 5px;"),
                            actionButton("lmm_run", "Run LMM", class = "btn-success"),
                            tags$div(style = "margin-top: 5px;"),
                            actionButton("lmm_check", "Check Assumptions", class = "btn-primary"),
                            tags$div(style = "margin-top: 5px;"),
                            actionButton("lmm_plot", "Plot Effects", class = "btn-info")
                          ),
                          mainPanel(
                            tabsetPanel(
                              id = "lmm_tabs",
                              tabPanel("Dependent Variable Normality",
                                       fluidRow(
                                         column(6,
                                                plotOutput("lmm_hist_before"),
                                                downloadButton("lmm_download_hist_before", "Download Before")),
                                         column(6,
                                                conditionalPanel(
                                                  condition = "input.lmm_transform != 'none'",
                                                  plotOutput("lmm_hist_after"),
                                                  downloadButton("lmm_download_hist_after", "Download After")
                                                )))),
                              tabPanel("Test Result", 
                                       uiOutput("lmm_warning_msg"),
                                       uiOutput("lmm_id_warning_msg"),
                                       verbatimTextOutput("lmm_result")),
                              tabPanel("Assumptions",
                                       uiOutput("lmm_id_warning_msg_assump"),
                                       plotOutput("lmm_assump", height = "700px"),
                                       br(),
                                       br(),
                                       br(),
                                       downloadButton("lmm_download_assump", "Download Assumption Plot")
                              ),
                              tabPanel("Effect Plot",
                                       uiOutput("lmm_id_warning_msg_effect"),
                                       plotOutput("lmm_effect", height = "550px", width = "600px"),
                                       br(),
                                       uiOutput("lmm_download_effect"))
                            )
                          )
                        )
                      )
             ),
             tabPanel("Logistic Regression",
                      fluidPage(
                        titlePanel("Logistic Regression"),
                        sidebarLayout(
                          sidebarPanel(
                            fileInput("log_file", "Upload CSV File", accept = ".csv"),
                            uiOutput("log_dep_ui"),
                            uiOutput("log_indep_ui"),
                            uiOutput("log_interact_ui"),
                            actionButton("log_run", "Run Logistic Regression", class = "btn-success"),
                            tags$div(style = "margin-top: 5px;"),
                            actionButton("log_check", "Check Assumptions", class = "btn-primary"),
                            tags$div(style = "margin-top: 5px;"),
                            actionButton("log_plot", "Plot Effects", class = "btn-info")
                          ),
                          mainPanel(
                            tabsetPanel(
                              id = "log_tabs",
                              tabPanel("Test Result", verbatimTextOutput("log_result")),
                              tabPanel("Assumptions",
                                       plotOutput("log_assump", height = "700px"),
                                       br(),
                                       downloadButton("log_download_assump", "Download Assumption Plot")),
                              tabPanel("Effect Plot",
                                       plotOutput("log_effect", height = "550px", width = "600px"),
                                       br(),
                                       downloadButton("log_download_effect", "Download Effect Plot"))
                            )
                          )
                        )
                      )
             ),
             tabPanel("Multinomial Regression",
                      fluidPage(
                        titlePanel("Multinomial Regression"),
                        sidebarLayout(
                          sidebarPanel(
                            fileInput("multi_file", "Upload CSV File", accept = ".csv"),
                            uiOutput("multi_dep_ui"),
                            uiOutput("multi_indep_ui"),
                            uiOutput("multi_interact_ui"),
                            actionButton("multi_run", "Run Multinomial Model", class = "btn-success"),
                            tags$div(style = "margin-top: 5px;"),
                            actionButton("multi_check", "Check Assumptions", class = "btn-primary")
                          ),
                          mainPanel(
                            tabsetPanel(
                              id = "multi_tabs",
                              tabPanel("Test Result", verbatimTextOutput("multi_result")),
                              tabPanel("Assumptions",
                                       plotOutput("multi_assump", height = "700px"),
                                       br(),
                                       downloadButton("multi_download_assump", "Download Assumption Plot"))
                            )
                          )
                        )
                      )
             ),
             tabPanel("Negative Binomial",
                      fluidPage(
                        titlePanel("Negative Binomial Regression"),
                        sidebarLayout(
                          sidebarPanel(
                            fileInput("nb_file", "Upload CSV File", accept = ".csv"),
                            uiOutput("nb_dep_ui"),
                            uiOutput("nb_indep_ui"),
                            uiOutput("nb_interact_ui"),
                            actionButton("nb_run", "Run Negative Binomial", class = "btn-success"),
                            tags$div(style = "margin-top: 5px;"),
                            actionButton("nb_check", "Check Assumptions", class = "btn-primary"),
                            tags$div(style = "margin-top: 5px;"),
                            actionButton("nb_plot", "Plot Effects", class = "btn-info")
                          ),
                          mainPanel(
                            tabsetPanel(
                              id = "nb_tabs",
                              tabPanel("Test Result", verbatimTextOutput("nb_result")),
                              tabPanel("Assumptions",
                                       plotOutput("nb_assump", height = "700px"),
                                       br(),
                                       downloadButton("nb_download_assump", "Download Assumption Plot")),
                              tabPanel("Effect Plot",
                                       plotOutput("nb_effect", height = "550px", width = "600px"),
                                       br(),
                                       downloadButton("nb_download_effect", "Download Effect Plot"))
                            )
                          )
                        )
                      )
             )
           ),

  tabPanel("Correlation",
           fluidPage(
             #titlePanel("Correlation Analysis"),
             sidebarLayout(
               sidebarPanel(
                 fileInput("cor_file", "Upload CSV File", accept = ".csv"),
                 div(
                   style = "font-size: 0.92em; color: #222; margin-bottom: 20px; margin-top: -15px;",
                   icon("info-circle", lib = "font-awesome"),
                   "Upload a table with samples in rows and features (variables) in columns."
                 ),
                 uiOutput("cor_feature_selector"),
                 checkboxInput("cor_select_all", "Select All Variables", value = FALSE),
                 div(
                   style = "font-size: 0.9em; color: #555; margin-bottom: 8px; margin-top: -15px;",
                   icon("info-circle", lib = "font-awesome"),
                   "Tip: Select exactly 2 variables to check Pearson assumptions, or use 'Select All' for a full correlation matrix."
                 ),
                 tags$div(style = "margin-top: 20px;"),
                 checkboxInput(
                   "cor_do_clr",
                   "Apply CLR transformation",
                   value = FALSE
                 ),
                 uiOutput("cor_clr_warning"),
                 fluidRow(
                   column(12,
                          tags$div(style = "margin-top: 10px;"),
                          sliderInput(
                            "cor_prev_filter",
                            label = tagList(
                              "Remove features present in less than (%):",
                              tags$span(
                                icon("info-circle", class = "fa-solid"),
                                `data-bs-toggle` = "tooltip",
                                `data-bs-placement` = "right",
                                title = "Tip: For compositional data, filter out low-prevalence features to reduce noise and improve interpretability. Use a higher threshold to focus on common features, or a lower one if rare features are important.",
                                style = "color:#2c3e50; font-size:16px; margin-left:5px; cursor: pointer;"
                              )
                            ),
                            min = 0, max = 50, value = 0, step = 5
                          )
                   )
                 ),
                 selectInput(
                   "cor_method", "Correlation Method",
                   choices = c(
                     "Choose Method" = "",
                     "Pearson" = "pearson",
                     "Spearman" = "spearman",
                     "Kendall" = "kendall",
                     "Biweight midcorrelation (bicor)" = "biweight"
                   ),
                   selected = ""
                 ),
                 selectInput(
                   "cor_p_adjust", "P-value adjustment method",
                   choices = c(
                     "Benjamini-Hochberg (BH)" = "BH",
                     "Bonferroni" = "bonferroni",
                     "Holm" = "holm",
                     "Hommel" = "hommel",
                     "Benjamini-Yekutieli (BY)" = "BY",
                     "FDR" = "fdr",
                     "None" = "none"
                   ),
                   selected = "BH"
                 ),
                 uiOutput("cor_assumption_ui"),
                 actionButton("cor_check_assumptions", "Check Assumptions", class = "btn-primary"),
                 actionButton("cor_run", "Run Correlation", class = "btn-success")
               ),
               mainPanel(
                 tabsetPanel(
                   id = "cor_tabs",
                   tabPanel(
                     "Assumption Tests",
                     uiOutput("cor_feature_warning_msg"),
                     tags$div(style = "margin-top: 10px;"),
                     uiOutput("cor_show_screenshot_btn"),
                     div(id = "cor_report_content", uiOutput("cor_assumption_content"))
                   ),
                   tabPanel(
                     "Test Results",
                     uiOutput("cor_result_content"),
                     uiOutput("cor_table_ui"),
                     uiOutput("cor_heatmap_ui"),
                     uiOutput("cor_download_heatmap_ui"),
                     uiOutput("cor_matrix_download_ui"),
                     uiOutput("cor_download_table_ui")
                   )
                 )
               )
             )
           )
  ),

  tabPanel(
    title = tagList(icon("circle-info"), "Help"),

    div(
      style = "max-width: 900px; margin: auto; padding: 20px;",

      # Title & Purpose
      h3(icon("question-circle", style = "margin-right: 10px; color: #3A9BB2;") , "How to Use AssumpSure",
         style = "color: #2c3e50; font-weight: 600;"),

      p("Follow these steps to get started:",
        style = "color: #444;"),

      tags$ol(
        style = "color: #444; line-height: 1.6;",
        tags$li("Upload your data in CSV format (see below for sample data)."),
        tags$li("Select the appropriate statistical test or model (see below)."),
        tags$li("Check assumptions using built-in visualizations and tests."),
        tags$li("AssumpSure will evaluate your choice and guide you if a different test is more appropriate."),
        tags$li("Run the analysis and interpret results with confidence."),
        tags$li("Download plots and tables for use in reports or publications.")
      ),

      hr(),

      # Sample Data Section
      h4(icon("download", style = "margin-right: 8px; color: #E3A599;"), "Try with Sample Data",
         style = "color: #2c3e50; margin-top: 30px; font-weight: 600;"),

      p("To understand the expected format and test the app features, download and explore the sample dataset:"),

      div(
        style = "text-align: center; margin: 20px 0; padding: 20px; border-radius: 12px; background-color: #f0f7fb; border: 1px solid #ddd;",

        icon("file-csv", class = "fa-2x", style = "color: #3A9BB2; margin-bottom: 10px;"),
        h5("Sample Data for Testing", style = "margin-bottom: 10px; font-weight: 600;"),
        a(href = "https://github.com/Ahmedbargheet/AssumpSure/tree/main/inst/extdata/infants.csv", # correct
          "Download Sample Data (CSV)",
          target = "_blank",
          style = "font-size: 16px; text-decoration: none; color: #3A9BB2; font-weight: 500;"
        )
      ),

      p("The sample file includes an example of long-format data with timepoints, groups, and numeric variables.",
        style = "font-size: 0.9em; color: #666; text-align: center;"),

      hr(),

      # Data Format Requirements
      h4(icon("table", style = "margin-right: 8px; color: #3D9DB3;"), "Data Format Guidelines",
         style = "color: #2c3e50; margin-top: 30px; font-weight: 600;"),

      tags$ul(
        style = "color: #444; list-style: none; padding-left: 0;",
        tags$li(icon("check-circle", style = "color: #3A9BB2; margin-right: 10px;"), "Use ", strong("long format"), ": one row per subject/timepoint"),
        tags$li(icon("check-circle", style = "color: #3A9BB2; margin-right: 10px;"), "For longitudinal studies, name your time variable exactly", code("timepoint")),
      ),

      hr(),

      # Supported Tests
      h4(icon("vial", style = "margin-right: 8px; color: #9EC2D1;"), "Supported Statistical Tools",
         style = "color: #2c3e50; font-weight: 600;"),

      p("AssumpSure supports a wide range of parametric and nonparametric tests, including:", style = "color: #444; margin-top: 10px;"),

      fluidRow(
        column(6,
               tags$ul(
                 style = "color: #444;",
                 tags$li(icon("dot-circle", style = "color: #3A9BB2; margin-right: 10px;"), "T-tests (independent & paired)"),
                 tags$li(icon("dot-circle", style = "color: #3A9BB2; margin-right: 10px;"), "ANOVA (one-way)"),
                 tags$li(icon("dot-circle", style = "color: #3A9BB2; margin-right: 10px;"), "Mann-Whitney U Test"),
                 tags$li(icon("dot-circle", style = "color: #3A9BB2; margin-right: 10px;"), "Wilcoxon Signed-Rank Test"),
                 tags$li(icon("dot-circle", style = "color: #3A9BB2; margin-right: 10px;"), "Kruskal-Wallis Test")
               )
        ),
        column(6,
               tags$ul(
                 style = "color: #444;",
                 tags$li(icon("dot-circle", style = "color: #3A9BB2; margin-right: 10px;"), "Chi-square & Fisher’s Exact Test"),
                 tags$li(icon("dot-circle", style = "color: #3A9BB2; margin-right: 10px;"), "Linear and mixed-effects regression models"),
                 tags$li(icon("dot-circle", style = "color: #3A9BB2; margin-right: 10px;"), "Logistic & Multinomial Regression"),
                 tags$li(icon("dot-circle", style = "color: #3A9BB2; margin-right: 10px;"), "Negative Binomial Regression"),
                 tags$li(icon("dot-circle", style = "color: #3A9BB2; margin-right: 10px;"), "Correlation analyses")
               )
        )
      ),

      hr(),


      # How to Choose the Right Test
      h4(icon("question-circle", style = "margin-right: 8px; color: #F2E099;"),
         "How to Choose the Right Test",
         style = "color: #2c3e50; font-weight: 600;"),

      p("Not sure which test to run? Use these simple rules based on your data type. AssumpSure will also suggest the correct test if assumptions aren't met.",
        style = "color: #444; margin-top: 10px;"),

      tags$ul(
        style = "color: #444;",

        tags$li(
          icon("check-circle", style = "color: #3A9BB2; margin-right: 8px;"),
          "If your dependent variable is continuous (e.g., height, weight, expression values):"
        ),
        tags$ul(
          style = "margin-top: -5px;",
          tags$li("Two independent groups (e.g., treatment vs. control): use an ", strong("Independent T-test")),
          tags$li("Same subjects measured twice (e.g., before and after): use a ", strong("Paired T-test")),
          tags$li("More than two groups (e.g., red, blue, green): use ", strong("One-way ANOVA"))
        ),

        tags$li(
          icon("check-circle", style = "color: #3A9BB2; margin-right: 8px;"),
          "If your dependent variable is a category with two levels (e.g., Yes/No): use ", strong("Logistic Regression")
        ),

        tags$li(
          icon("check-circle", style = "color: #3A9BB2; margin-right: 8px;"),
          "If your dependent variable is a category with more than two levels: use ", strong("Multinomial Regression")
        ),

        tags$li(
          icon("check-circle", style = "color: #3A9BB2; margin-right: 8px;"),
          "If your dependent variable is a count (e.g., number of visits, gene reads): use ", strong("Negative Binomial Regression")
        ),

        tags$li(
          icon("check-circle", style = "color: #3A9BB2; margin-right: 8px;"),
          "If you're examining the relationship between two continuous variables: use a ", strong("Correlation test (Pearson, Spearman, etc.)")
        ),

        tags$li(
          icon("check-circle", style = "color: #3A9BB2; margin-right: 8px;"),
          "If you have two categorical variables (e.g., gender and response):"
        ),
        tags$ul(
          style = "margin-top: -5px;",
          tags$li("Use ", strong("Fisher’s Exact Test"), " if any cell count is < 5"),
          tags$li("Otherwise, use ", strong("Chi-square Test"))
        ),

        tags$li(
          icon("check-circle", style = "color: #3A9BB2; margin-right: 8px;"),
          "If your outcome is continuous and your model includes multiple predictors: use a ",
          strong("Linear Model (LM)")
        ),

        tags$li(
          icon("check-circle", style = "color: #3A9BB2; margin-right: 8px;"),
          "If you have repeated measures or hierarchical data (e.g., patient ID): use a ",
          strong("Linear Mixed Model (LMM)")
        )),

  hr(),


      # Troubleshooting Tips
      h4(icon("bug", style = "margin-right: 8px; color: #E3A599;"), "Troubleshooting",
         style = "color: #2c3e50; font-weight: 600;"),

      tags$ul(
        style = "color: #444;",
        tags$li("If a test button is disabled, make sure all required variables are selected."),
        tags$li("For assumption warnings, check the data distribution and consider transformations if needed."),
        tags$li("Ensure timepoint is correctly labeled as 'timepoint' for longitudinal models.")
      ),

      hr(),

      # Contact Info
  h4(icon("envelope", style = "margin-right: 8px; color: #E3A599;"), "Need Help?",
     style = "color: #2c3e50; font-weight: 600;"),

  p(
    HTML('For feedback, questions, or bug reports, please contact us <a href="mailto:ahmed.bargheet@yahoo.com" style="color: #3A9BB2; text-decoration: underline;">HERE</a>.'),
    style = "color: #444; text-align: left; margin-top: 10px;"
  ),

      div(
        style = "text-align: center; margin-top: 20px; font-size: 0.9em; color: #666;",
        "You can also find this app on GitHub for updates and documentation."
      ),

      div(
        style = "text-align: center; margin-top: 10px;",
        a(href = "https://github.com/Ahmedbargheet/AssumpSure", target = "_blank", # correct
          icon("github", style = "font-size: 24px; color: #2c3e50;"),
          " Visit on GitHub",
          style = "text-decoration: none; color: #2c3e50;"
        )
      )
    )
  )

)

#
#
#
#

# ----- SERVER -----
server <- function(input, output, session) {

  # --- Data Loader ---
  data <- reactive({
    req(input$file)
    tryCatch({
      df <- readr::read_csv(input$file$datapath, col_types = cols(.default = "c"), show_col_types = FALSE,
                            na = c("", "NA", "N/A", "null"))
      
      # Convert to appropriate types
      df[] <- lapply(df, function(col) {
        # Try numeric first
        num_col <- suppressWarnings(as.numeric(col))
        if (!any(is.na(num_col)) && length(unique(num_col)) > 10) {
          return(num_col)  # continuous
        } else if (length(unique(col)) <= 10) {
          return(factor(col))  # categorical
        } else {
          return(col)  # leave as is
        }
      })
      
      df
    }, error = function(e) {
      showNotification(paste("Error reading file:", e$message), type = "error")
      NULL
    })
  })
  
  # --- Column selectors (dynamic) ---
  output$column_selectors <- renderUI({
    df <- data()
    req(df)
    
    # Continuous: numeric with many unique values
    numeric_vars <- names(df)[sapply(df, function(col) {
      is.numeric(col) &&
        length(unique(col)) > 10 &&
        any(col %% 1 != 0, na.rm = TRUE)  # Exclude if all values are integers
    })]
    
    # Categorical: factor or character with few unique values
    cat_vars <- names(df)[sapply(df, function(col) {
      is.factor(col) || (is.character(col) && length(unique(col)) <= 10)
    })]
    
    tagList(
      selectInput("value_col", "Select Numeric Value Column (continuous):",
                  choices = c("Choose" = "", numeric_vars)),
      selectInput("group_col", "Select Group/Condition Column (categorical):",
                  choices = c("Choose" = "", cat_vars))
    )
  })

  output$timepoint_ui <- renderUI({
    df <- data()
    req(df)
    
    if ("timepoint" %in% names(df)) {
      selectInput("timepoint",
                  label = "Select Timepoint (for longitudinal data):",
                  choices = c("Select timepoint" = "", as.character(unique(df$timepoint))),
                  selected = ""
      )
    }
  })
  
  # --- Reactive: processed data ---
  processed_data <- reactiveVal(NULL)
  run_test_clicked <- reactiveVal(FALSE)
  assumptions_met <- reactive({
    df <- processed_data()
    if (is.null(df)) return(FALSE)
    switch(
      input$test_type,
      "independent_ttest" = {
        normality <- shapiro_result()
        levene_res <- levene_result()
        if (is.null(normality) || is.null(levene_res)) return(FALSE)
        normality_passed <- if ("p" %in% names(normality)) all(normality$p > 0.05) else FALSE
        variance_passed <- if ("p" %in% names(levene_res)) levene_res$p > 0.05 else FALSE
        normality_passed && variance_passed
      },
      "dependent_ttest" = {
        tryCatch({
          group_levels <- levels(df$group)
          if (length(group_levels) != 2) stop("Need exactly 2 groups for paired t-test.")
          v1 <- df %>% filter(group == group_levels[1]) %>% pull(value)
          v2 <- df %>% filter(group == group_levels[2]) %>% pull(value)
          n <- min(length(v1), length(v2))
          if (n < 3) stop("Not enough data in one or both groups.")
          diff <- v1[1:n] - v2[1:n]
          shapiro_diff <- shapiro_test(diff)
          normality_passed <- if ("p.value" %in% names(shapiro_diff)) shapiro_diff$p.value > 0.05 else FALSE
          normality_passed
        }, error = function(e) {
          showNotification(paste("Error in paired t-test assumption check:", e$message), type = "error")
          FALSE
        })
      },
      "anova" = {
        normality <- shapiro_result()
        levene_res <- levene_result()
        if (is.null(normality) || is.null(levene_res)) return(FALSE)
        normality_passed <- if ("p" %in% names(normality)) all(normality$p > 0.05) else FALSE
        variance_passed <- if ("p" %in% names(levene_res)) levene_res$p > 0.05 else FALSE
        normality_passed && variance_passed
      },
      "mannwhitney" = TRUE, # Always true for Mann-Whitney
      "wilcoxon_signed" = TRUE,
      "kruskal" = TRUE,
      FALSE
    )
  })

  # Make the plot_boxplot and download_boxplot disappear when the assumption is not met
  observe({
    test_type <- input$test_type
    df <- processed_data()
    ngroups <- if (!is.null(df)) nlevels(df$group) else 0

    if (
      (test_type %in% c("mannwhitney", "wilcoxon_signed") && ngroups != 2) ||
      !assumptions_met()
    ) {
      shinyjs::disable("plot_boxplot")
      shinyjs::hide("plot_boxplot")
      shinyjs::disable("download_boxplot")
      shinyjs::hide("download_boxplot")
    } else {
      shinyjs::enable("plot_boxplot")
      shinyjs::show("plot_boxplot")
      shinyjs::enable("download_boxplot")
      shinyjs::show("download_boxplot")
    }
  })

  # Deactivate the assumption button for Mann-Whitney
  observe({
    if (input$test_type %in% c("mannwhitney", "wilcoxon_signed", "kruskal")) {
      shinyjs::disable("check_assumptions")
    } else {
      shinyjs::enable("check_assumptions")
    }
  })


  # Reset everything when the user changes anything
  reset_results <- function() {
    output$test_result_with_square <- renderUI({ NULL })
    output$boxplot <- renderPlot({ NULL })
    output$actual_test_result <- renderPrint({ NULL })
    output$posthoc_result <- renderPrint({ NULL })
    output$posthoc_result_ui <- renderUI({ NULL })
    run_test_clicked(FALSE)
  }

  # Show the post hoc results area only when button is pressed
  observeEvent(input$run_posthoc, {
    output$posthoc_result_ui <- renderUI({
      verbatimTextOutput("posthoc_result")
    })
    # (rest of your code to render posthoc_result itself)
  })

  observeEvent(input$file,      { processed_data(NULL); reset_results() })
  observeEvent(input$test_type, { processed_data(NULL); reset_results() })
  observeEvent(input$value_col, { processed_data(NULL); reset_results() })
  observeEvent(input$group_col, { processed_data(NULL); reset_results() })

  observeEvent(input$test_type, {
    assumptions_checked(FALSE)
  })
  observeEvent(input$value_col, {
    assumptions_checked(FALSE)
  })
  observeEvent(input$group_col, {
    assumptions_checked(FALSE)
  })
  observeEvent(input$file, {
    assumptions_checked(FALSE)
  })



  # --- Prepare data for assumptions/testing ---
  observeEvent(input$check_assumptions, {
    
    # ---- Required Input Checks (for Check Assumptions) ----
    if (is.null(input$file)) {
      showNotification(strong("Please upload a data file."), type = "error")
      return()
    }
    if (is.null(input$test_type) || input$test_type == "") {
      showNotification(strong("Please select a statistical test."), type = "error")
      return()
    }
    if (is.null(input$value_col) || input$value_col == "") {
      showNotification(strong("Please select a numeric value column."), type = "error")
      return()
    }
    if (is.null(input$group_col) || input$group_col == "") {
      showNotification(strong("Please select a group/condition column."), type = "error")
      return()
    }
    
    assumptions_checked(TRUE)
    req(data(), input$value_col, input$group_col)
    df0 <- data()
    if (!is.null(input$timepoint) && input$timepoint != "" && "timepoint" %in% names(df0)) {
      df0 <- dplyr::filter(df0, timepoint == input$timepoint)
    }
    # Check column types BEFORE further processing
    value_is_numeric <- is.numeric(type.convert(df0[[input$value_col]], as.is = TRUE))
    group_is_factor  <- is.factor(as.factor(df0[[input$group_col]]))
    group_is_numeric <- is.numeric(type.convert(df0[[input$group_col]], as.is = TRUE))

    if (!value_is_numeric) {
      showNotification(strong("The selected value column is not numeric. Please select a numeric column."), 
                       type = "error")
      return()
    }
    if (group_is_numeric) {
      showNotification(strong("The selected group column is numeric. Please select a categorical (group) column."), type = "error")
      return()
    }

    # Proceed as normal
    df <- df0 %>%
      dplyr::select(value = !!sym(input$value_col), group = !!sym(input$group_col)) %>%
      mutate(value = as.numeric(as.character(value)),
             group = as.factor(group)) %>%
      filter(!is.na(value), !is.na(group)) %>%
      droplevels()
    # New: Minimum checks
    ngroups <- nlevels(df$group)
    if (input$test_type == "independent_ttest" && (ngroups != 2 || any(table(df$group) < 2))) {
      showNotification(strong("More than two groups detected. Please use One-way ANOVA. Independent t-test is only for comparing exactly two groups."), type = "error")
      return()
    }
    if (input$test_type == "dependent_ttest") {
      counts <- table(df$group)
      ngroups <- length(counts)
      group_sizes <- as.numeric(counts)
      
      if (ngroups != 2) {
        showNotification(strong("More than two groups detected. Please use One-way ANOVA. Paired t-test is only for comparing exactly two groups."), type = "error", duration = 3)
        return()
      }
      if (length(unique(group_sizes)) > 1) {
        showNotification(strong("Paired t-test requires both groups to have equal sample size. If your data are not truly paired, consider using the independent t-test. Otherwise, check your data for missing or unmatched pairs."), type = "error", duration = 6)
        return()
      }
      if (any(group_sizes < 3)) {
        showNotification(strong("Paired t-test requires at least 3 samples in each group."), type = "error")
        return()
      }
    }
    
    # ---- ANOVA GROUP CHECK ----
    if (input$test_type == "anova" && ngroups < 3) {
      showNotification(strong("Only two groups detected. Please use a t-test (independent or paired, as appropriate). One-way ANOVA is for three or more groups."), type = "error", duration = 5)
      return()
    }
    processed_data(df)
  })

  # For Mann-Whitney: always prep data when test is run and assumptions button is disabled
  observeEvent({
    input$run_test
    input$test_type
  }, {
    if (input$test_type == "mannwhitney") {
      req(data(), input$value_col, input$group_col)
      df0 <- data()
      if (!is.null(input$timepoint) && input$timepoint != "" && "timepoint" %in% names(df0)) {
        df0 <- dplyr::filter(df0, timepoint == input$timepoint)
      }
      value_is_numeric <- is.numeric(type.convert(df0[[input$value_col]], as.is = TRUE))
      group_is_numeric <- is.numeric(type.convert(df0[[input$group_col]], as.is = TRUE))
      if (!value_is_numeric) {
        showNotification(strong("The selected value column is not numeric. Please select a numeric column."), 
                         type = "error")
        return()
      }
      if (group_is_numeric) {
        showNotification(strong("The selected group column is numeric. Please select a categorical (group) column."), type = "error")
        return()
      }
      df <- df0 %>%
        dplyr::select(value = !!sym(input$value_col), group = !!sym(input$group_col)) %>%
        mutate(value = as.numeric(as.character(value)),
               group = as.factor(group)) %>%
        filter(!is.na(value), !is.na(group)) %>%
        droplevels()
      processed_data(df)
    }
  }, ignoreInit = TRUE)

  # For Wilcoxon signed-rank: always prep data when test is run and assumptions button is disabled
  observeEvent({
    input$run_test
    input$test_type
  }, {
    if (input$test_type == "wilcoxon_signed") {
      req(data(), input$value_col, input$group_col)
      df0 <- data()
      if (!is.null(input$timepoint) && input$timepoint != "" && "timepoint" %in% names(df0)) {
        df0 <- dplyr::filter(df0, timepoint == input$timepoint)
      }
      value_is_numeric <- is.numeric(type.convert(df0[[input$value_col]], as.is = TRUE))
      group_is_numeric <- is.numeric(type.convert(df0[[input$group_col]], as.is = TRUE))
      if (!value_is_numeric) {
        showNotification(strong("The selected value column is not numeric. Please select a numeric column."), 
                         type = "error")
        return()
      }
      if (group_is_numeric) {
        showNotification(strong("The selected group column is numeric. Please select a categorical (group) column."), type = "error")
        return()
      }
      df <- df0 %>%
        dplyr::select(value = !!sym(input$value_col), group = !!sym(input$group_col)) %>%
        mutate(value = as.numeric(as.character(value)),
               group = as.factor(group)) %>%
        filter(!is.na(value), !is.na(group)) %>%
        droplevels()
      processed_data(df)
    }
  }, ignoreInit = TRUE)

  # For Kruskal–Wallis: always prep data when test is run and assumptions button is disabled
  observeEvent({
    input$run_test
    input$test_type
  }, {
    if (input$test_type == "kruskal") {
      req(data(), input$value_col, input$group_col)
      df0 <- data()
      if (!is.null(input$timepoint) && input$timepoint != "" && "timepoint" %in% names(df0)) {
        df0 <- dplyr::filter(df0, timepoint == input$timepoint)
      }
      value_is_numeric <- is.numeric(type.convert(df0[[input$value_col]], as.is = TRUE))
      group_is_numeric <- is.numeric(type.convert(df0[[input$group_col]], as.is = TRUE))
      if (!value_is_numeric) {
        showNotification(strong("The selected value column is not numeric. Please select a numeric column."), 
                         type = "error")
        return()
      }
      if (group_is_numeric) {
        showNotification(strong("The selected group column is numeric. Please select a categorical (group) column."), type = "error")
        return()
      }
      df <- df0 %>%
        dplyr::select(value = !!sym(input$value_col), group = !!sym(input$group_col)) %>%
        mutate(value = as.numeric(as.character(value)),
               group = as.factor(group)) %>%
        filter(!is.na(value), !is.na(group)) %>%
        droplevels()
      processed_data(df)
    }
  }, ignoreInit = TRUE)


 # Run the Post hoc test
  observeEvent(input$run_posthoc, {
    df <- processed_data()
    method <- input$posthoc_method
    if (is.null(df) || is.null(method)) return()

    if (input$test_type == "kruskal") {
      posthoc <- tryCatch({
        rstatix::dunn_test(df, value ~ group, p.adjust.method = method)
      }, error = function(e) data.frame(error = e$message))
    } else if (input$test_type == "anova") {
      if (method == "tukey") {
        posthoc <- tryCatch({
          rstatix::tukey_hsd(df, value ~ group)
        }, error = function(e) data.frame(error = e$message))
      } else {
        posthoc <- tryCatch({
          rstatix::pairwise_t_test(df, value ~ group, p.adjust.method = method)
        }, error = function(e) data.frame(error = e$message))
      }
    } else {
      posthoc <- NULL
    }

    output$posthoc_result <- renderPrint({
      if (!is.null(posthoc)) posthoc %>% knitr::kable(align = "c", "simple")
    })
  })


  # --- Assumption Content UI ---

# Independent t-test
assumption_ui_independent <- function() {
  lev_res <- levene_result()
  shap_res <- shapiro_result()
  has_check_error <- is.null(lev_res) || is.null(shap_res)
  lev_p <- if (!is.null(lev_res) && "p" %in% names(lev_res)) lev_res$p[1] else NA
  shap_p <- if (!is.null(shap_res) && "p" %in% names(shap_res)) shap_res$p else NA
  shap_failed <- if (!is.na(shap_p[1])) any(shap_p <= 0.05) else FALSE
  tagList(
    br(),
    h4("Assumption Test Results"),
    div(
      h5("Levene's Test (Equal Variance)"),
      div(style = "background-color: #f0f0f0; padding: 10px; border-radius: 5px;",
          verbatimTextOutput("levene_text")),
      if (!is.na(lev_p))
        div(
          style = paste0("background-color: ", if (lev_p <= 0.05) "#B20D00" else "green",
                         "; color: white; padding: 10px; border-radius: 5px; margin-top: 10px;"),
          strong(
            if (lev_p <= 0.05)
              "Variances are significantly different (Heterogeneous)"
            else
              "Variances are equal (Homogeneous)"
          )
        )
    ),
    div(
      br(),
      h5("Shapiro-Wilk Test (Normality)"),
      div(style = "background-color: #f0f0f0; padding: 10px; border-radius: 5px;",
          verbatimTextOutput("shapiro_text")),
      if (!is.na(shap_p[1]))
        div(
          style = paste0("background-color: ", if (shap_failed) "#B20D00" else "green",
                         "; color: white; padding: 10px; border-radius: 5px; margin-top: 10px;"),
          strong(
            if (shap_failed)
              "Data deviates from normal distribution"
            else
              "Data appears to be normally distributed"
          )
        )
    ),
    br(),
    h4("Diagnostic Plots"),
    fluidRow(
      column(6, plotOutput("qq_plot"), downloadButton("download_qq", "Download Q-Q Plot", class = "no-print")),
      column(6, plotOutput("histogram_plot"), downloadButton("download_histogram", "Download Histogram", 
                                                             class = "no-print"))
    ),
    br(),
    h4("Assumption Check Summary"),
    uiOutput("assumption_summary")
  )
}

# Dependent t-test
assumption_ui_dependent <- function() {
  shap_res <- shapiro_result()
  shap_p <- if (!is.null(shap_res) && "p.value" %in% names(shap_res)) shap_res$p.value[1] else NA
  tagList(
    br(),
    h4("Assumption Test Results (Paired T-test)"),
    div(
      h5("Shapiro-Wilk Test (Normality of Differences)"),
      div(style = "background-color: #f0f0f0; padding: 10px; border-radius: 5px;",
          verbatimTextOutput("shapiro_text")),
      if (is.numeric(shap_p) && !is.na(shap_p) && length(shap_p) == 1)
        div(
          style = paste0("background-color: ", if (shap_p <= 0.05) "#B20D00" else "green",
                         "; color: white; padding: 10px; border-radius: 5px; margin-top: 10px;"),
          strong(
            if (shap_p <= 0.05)
              "Differences are not normally distributed"
            else
              "Differences appear to be normally distributed"
          )
        )
    ),
    br(),
    h4("Diagnostic Plots"),
    fluidRow(
      column(6, plotOutput("qq_plot"), downloadButton("download_qq", "Download Q-Q Plot", class = "no-print")),
      column(6, plotOutput("histogram_plot"), downloadButton("download_histogram", "Download Histogram", 
                                                             class = "no-print"))
    ),
    br(),
    h4("Assumption Check Summary"),
    uiOutput("assumption_summary")
  )
}

# One-way ANOVA
assumption_ui_anova <- function() {
  lev_res <- levene_result()
  shap_res <- shapiro_result()
  has_check_error <- is.null(lev_res) || is.null(shap_res)
  lev_p <- if (!is.null(lev_res) && "p" %in% names(lev_res)) lev_res$p[1] else NA
  shap_p <- if (!is.null(shap_res) && "p" %in% names(shap_res)) shap_res$p else NA
  shap_failed <- if (!is.na(shap_p[1])) any(shap_p <= 0.05) else FALSE
  tagList(
    br(),
    h4("Assumption Test Results"),
    div(
      h5("Levene's Test (Equal Variance)"),
      div(style = "background-color: #f0f0f0; padding: 10px; border-radius: 5px;",
          verbatimTextOutput("levene_text")),
      if (!is.na(lev_p))
        div(
          style = paste0("background-color: ", if (lev_p <= 0.05) "#B20D00" else "green",
                         "; color: white; padding: 10px; border-radius: 5px; margin-top: 10px;"),
          strong(
            if (lev_p <= 0.05)
              "Variances are significantly different (Heterogeneous)"
            else
              "Variances are equal (Homogeneous)"
          )
        )
    ),
    div(
      br(),
      h5("Shapiro-Wilk Test (Normality)"),
      div(style = "background-color: #f0f0f0; padding: 10px; border-radius: 5px;",
          verbatimTextOutput("shapiro_text")),
      if (!is.na(shap_p[1]))
        div(
          style = paste0("background-color: ", if (shap_failed) "#B20D00" else "green",
                         "; color: white; padding: 10px; border-radius: 5px; margin-top: 10px;"),
          strong(
            if (shap_failed)
              "Data deviates from normal distribution"
            else
              "Data appears to be normally distributed"
          )
        )
    ),
    br(),
    h4("Diagnostic Plots"),
    {
      lev_res <- levene_result()
      shap_res <- shapiro_result()
      has_check_error <- is.null(lev_res) || is.null(shap_res)
      if (!has_check_error) {
        fluidRow(
          column(6, plotOutput("qq_plot"), downloadButton("download_qq", "Download Q-Q Plot", class = "no-print")),
          column(6, plotOutput("histogram_plot"), downloadButton("download_histogram", "Download Histogram", 
                                                                 class = "no-print"))
        )
      } else {
        div(style = "color: #b00; margin: 10px 0;",
            "Diagnostic plots are not available because the assumption checks could not be performed (missing or invalid data).")
      }
    },
    br(),
    h4("Assumption Check Summary"),
    uiOutput("assumption_summary")
  )
}

# --- Refactored renderUI using switch ---
output$assumption_content <- renderUI({
  if (is.null(processed_data())) return(NULL)
  switch(
    input$test_type,
    "independent_ttest" = assumption_ui_independent(),
    "dependent_ttest" = assumption_ui_dependent(),
    "anova" = assumption_ui_anova(),
    ## add here
    NULL
  )
})

  # --- Shapiro-Wilk Output Functions ---
# Independent t-test
shapiro_text_independent <- function(df) {
  print(df %>% group_by(group) %>% shapiro_test(value))
}

# Dependent t-test
shapiro_text_dependent <- function(df) {
  group_levels <- levels(df$group)
  if (length(group_levels) != 2) {
    cat("Error: Need exactly 2 groups for paired test.")
    return()
  }
  values1 <- df %>% filter(group == group_levels[1]) %>% pull(value)
  values2 <- df %>% filter(group == group_levels[2]) %>% pull(value)
  if (length(values1) != length(values2) || length(values1) < 3) {
    cat("Cannot run paired test: Unequal or insufficient values per group. Check your data.")
    return()
  }
  diff <- values1 - values2
  print(shapiro_test(diff))
}

# ANOVA
shapiro_text_anova <- function(df) {
  print(df %>% group_by(group) %>% shapiro_test(value))
}

# shapiro_text_anova <- function(df) { ... }



# --- Refactored Shapiro Output renderPrint ---
output$shapiro_text <- renderPrint({
  df <- processed_data()
  if (is.null(df)) return(NULL)
  shap <- switch(
    input$test_type,
    "independent_ttest" = shapiro_result_independent(df),
    "dependent_ttest"   = shapiro_result_dependent(df),
    "anova"             = shapiro_result_anova(df),
    NULL
  )
  if (is.null(shap)) return(NULL)
  knitr::kable(shap, align = "c", "simple")
})


# Levene test
## independent t-test
output$levene_text <- renderPrint({
  lev <- levene_result()
  if (is.null(lev)) return(NULL)
  knitr::kable(lev, align = "c", "simple")
})


  # --- QQ Plot ---
# independent t-test
  qq_plot_independent <- function(df) {
    ggplot(df, aes(sample = value, color = group)) +
      stat_qq() +
      stat_qq_line(color = "#E41A1C") +
      facet_wrap(~group) +
      theme_test() +
      theme(plot.background = element_rect(fill = "white"))
  }

# Dependent t-test
  qq_plot_dependent <- function(df) {
    group_levels <- levels(df$group)
    if (length(group_levels) != 2) return()
    v1 <- df %>% filter(group == group_levels[1]) %>% pull(value)
    v2 <- df %>% filter(group == group_levels[2]) %>% pull(value)
    if (length(v1) != length(v2) || length(v1) < 3) return()
    diff <- v1 - v2
    ggplot(data.frame(diff = diff), aes(sample = diff)) +
      stat_qq() +
      stat_qq_line(color = "#E41A1C") +
      theme_test() +
      labs(title = "Q-Q Plot of Differences") +
      theme(plot.background = element_rect(fill = "white"))
  }


  # One-way ANOVA
  qq_plot_anova <- function(df) {
    ggplot(df, aes(sample = value, color = group)) +
      stat_qq() +
      stat_qq_line(color = "#E41A1C") +
      facet_wrap(~group) +
      theme_test() +
      theme(plot.background = element_rect(fill = "white"))
  }
  # q_plot_anova <- function(df) { ... }


  # --- Refactored QQ Plot renderPlot using switch ---

  output$qq_plot <- renderPlot({
    df <- processed_data()
    if (is.null(df)) return(NULL)
    switch(
      input$test_type,
      "independent_ttest" = qq_plot_independent(df),
      "dependent_ttest" = qq_plot_dependent(df),
      "anova" = qq_plot_anova(df),
      # add here
      NULL
    )
  })

  # --- Histogram Plot ---
# independent t-test
  histogram_plot_independent <- function(df) {
    ggplot(df, aes(x = value, fill = group)) +
      geom_histogram(aes(y = after_stat(density)), bins = 30, color = "black", fill = "#4db6ac", alpha = 0.7) +
      geom_density(color = "#b2182b", size = 1.2, alpha = 0.7, show.legend = FALSE) +
      facet_wrap(~group) +
      theme_test() +
      theme(plot.background = element_rect(fill = "white"))
  }

# Dependent t-test
  histogram_plot_dependent <- function(df) {
    group_levels <- levels(df$group)
    if (length(group_levels) != 2) return()
    v1 <- df %>% filter(group == group_levels[1]) %>% pull(value)
    v2 <- df %>% filter(group == group_levels[2]) %>% pull(value)
    if (length(v1) != length(v2) || length(v1) < 3) return()
    diff <- v1 - v2
    ggplot(data.frame(diff = diff), aes(x = diff)) +
      geom_histogram(aes(y = after_stat(density)), bins = 30, color = "black", fill = "#4db6ac", alpha = 0.7) +
      geom_density(color = "#b2182b", size = 1.2, alpha = 0.7, show.legend = FALSE) +
      theme_test() +
      labs(title = "Histogram of Differences") +
      theme(plot.background = element_rect(fill = "white"))
  }

  # One-way ANOVA
  histogram_plot_anova <- function(df) {
    ggplot(df, aes(x = value, fill = group)) +
      geom_histogram(aes(y = after_stat(density)), bins = 30, color = "black", fill = "#4db6ac", alpha = 0.7) +
      geom_density(color = "#b2182b", size = 1.2, alpha = 0.7, show.legend = FALSE) +
      facet_wrap(~group) +
      theme_test() +
      theme(plot.background = element_rect(fill = "white"))
  }

  # --- Modular renderPlot for Histogram ---
  output$histogram_plot <- renderPlot({
    df <- processed_data()
    if (is.null(df)) return(NULL)
    switch(
      input$test_type,
      "independent_ttest" = histogram_plot_independent(df),
      "dependent_ttest" = histogram_plot_dependent(df),
      "anova" = histogram_plot_anova(df),
      #add here
      NULL
    )
  })

  # --- Download QQ Plot ---
  output$download_qq <- downloadHandler(
    filename = function() {
      paste("qq_plot_", Sys.Date(), ".png", sep = "")
    },
    content = function(file) {
      df <- processed_data()
      if (is.null(df)) return(NULL)
      p <- switch(
        input$test_type,
        "independent_ttest" = qq_plot_independent(df),
        "dependent_ttest" = qq_plot_dependent(df),
        "anova" = qq_plot_anova(df),
        # add here
        NULL
      )
      if (is.null(p)) return(NULL)
      ggsave(file, plot = p, width = 6, height = 4, dpi = 600, bg = "white")
    }
  )


  # --- Download Histogram Plot ---
  output$download_histogram <- downloadHandler(
    filename = function() {
      paste("histogram_", Sys.Date(), ".png", sep = "")
    },
    content = function(file) {
      df <- processed_data()
      if (is.null(df)) return(NULL)
      p <- switch(
        input$test_type,
        "independent_ttest" = histogram_plot_independent(df),
        "dependent_ttest" = histogram_plot_dependent(df),
        "anova" = histogram_plot_anova(df),
        # add here
        NULL
      )
      if (is.null(p)) return(NULL)
      ggsave(file, plot = p, width = 6, height = 4, dpi = 600, bg = "white")
    }
  )

  # --- Assumption Summary ---

## Independent t-test
  assumption_summary_independent <- function(df) {
    normality <- shapiro_result()
    levene_result <- levene_result()
    normality_p <- if ("p" %in% names(normality)) normality$p else NA
    variance_p <- if ("p" %in% names(levene_result)) levene_result$p else NA
    variance_passed <- !is.na(variance_p) && variance_p > 0.05
    
    if (all(!is.na(normality_p)) && all(normality_p > 0.10) && variance_passed) {
      div(
        style = "background-color: green; color: white; padding: 10px; border-radius: 5px;",
        strong("✓ Assumptions Passed"),
        p("Parametric test (T-test) can be performed with confidence.")
      )
    } else if (any(!is.na(normality_p) & normality_p > 0.05 & normality_p <= 0.10) && variance_passed) {
      div(
        style = "background-color: #ffc107; color: #222; padding: 10px; border-radius: 5px;",
        strong("! Borderline normality"),
        p("Normality assumption is borderline (Shapiro-Wilk p = 0.05-0.1). Please check the histogram or QQ plot. When uncertain, Wilcoxon signed-rank test is a robust alternative.")
      )
    } else {
      div(
        style = "background-color: #B20D00; color: white; padding: 10px; border-radius: 5px;",
        strong("✗ Assumptions Not Met"),
        p("Consider the non-parametric alternative:", strong("Mann-Whitney U test."))
      )
    }
  }
  

  ## Dependent t-test
  assumption_summary_dependent <- function(df) {
    group_levels <- levels(df$group)
    if (length(group_levels) != 2) return()
    v1 <- df %>% filter(group == group_levels[1]) %>% pull(value)
    v2 <- df %>% filter(group == group_levels[2]) %>% pull(value)
    if (length(v1) != length(v2) || length(v1) < 3) {
      return(div(
        style = "background-color: orange; color: white; padding: 10px; border-radius: 5px;",
        strong("Cannot run paired test: Unequal or insufficient values per group. Check your data.")
      ))
    }
    diff <- v1 - v2
    shapiro_diff <- shapiro_test(diff)
    shapiro_p <- if ("p.value" %in% names(shapiro_diff)) shapiro_diff$p.value else NA
    
    if (!is.na(shapiro_p) && shapiro_p > 0.10) {
      div(
        style = "background-color: green; color: white; padding: 10px; border-radius: 5px;",
        strong("✓ Assumptions Passed"),
        p("Parametric paired t-test can be performed with confidence.")
      )
    } else if (!is.na(shapiro_p) && shapiro_p > 0.05 && shapiro_p <= 0.10) {
      div(
        style = "background-color: #ffc107; color: #222; padding: 10px; border-radius: 5px;",
        strong("! Borderline normality"),
        p(sprintf(
          "Normality assumption for paired differences is borderline (Shapiro-Wilk p = %.4f). Please check the histogram or QQ plot. When uncertain, Wilcoxon signed-rank test is a robust alternative.",
          shapiro_p
        ))
      )
    } else {
      div(
        style = "background-color: #B20D00; color: white; padding: 10px; border-radius: 5px;",
        strong("✗ Assumptions Not Met"),
        p("Consider a non-parametric alternative:", strong("Wilcoxon signed-rank test."))
      )
    }
  }
  

## One-way ANOVA
  assumption_summary_anova <- function(df) {
    normality <- shapiro_result()
    levene_res <- levene_result()
    if (is.null(normality) || is.null(levene_res)) return(NULL)
    pval_col <- if ("p" %in% names(normality)) "p" else if ("p.value" %in% names(normality)) "p.value" else NULL
    normality_p <- if (!is.null(pval_col)) na.omit(normality[[pval_col]]) else NA
    variance_p <- if ("p" %in% names(levene_res)) levene_res$p else NA
    variance_passed <- !is.na(variance_p) && variance_p > 0.05
    
    if (all(!is.na(normality_p)) && all(normality_p > 0.10) && variance_passed) {
      div(
        style = "background-color: green; color: white; padding: 10px; border-radius: 5px;",
        strong("✓ Assumptions Passed"),
        p("Parametric test (One-way ANOVA) can be performed with confidence.")
      )
    } else if (any(!is.na(normality_p) & normality_p > 0.05 & normality_p <= 0.10) && variance_passed) {
      div(
        style = "background-color: #ffc107; color: #222; padding: 10px; border-radius: 5px;",
        strong("! Borderline normality"),
        p("Normality assumption is borderline for one or more groups (Shapiro-Wilk p = 0.05-0.1). Please check the histograms or QQ plots. When uncertain, Kruskal–Wallis is a robust alternative."
        )
      )
    } else {
      div(
        style = "background-color: #B20D00; color: white; padding: 10px; border-radius: 5px;",
        strong("✗ Assumptions Not Met"),
        p("Consider a non-parametric alternative:", strong("Kruskal–Wallis test."))
      )
    }
  }
  

  output$assumption_summary <- renderUI({
    df <- processed_data()
    if (is.null(df)) return(NULL)
    switch(
      input$test_type,
      "independent_ttest" = assumption_summary_independent(df),
      "dependent_ttest" = assumption_summary_dependent(df),
      "anova" = assumption_summary_anova(df),
      # Add here for ANOVA or others later
      NULL
    )
  })

  # Levene's result (reactive)
  levene_result <- reactive({
    df <- processed_data()
    if (is.null(df)) return(NULL)
    if (all(is.na(df$group))) {
      showNotification(strong("Group column contains only NA. Please select a valid grouping variable."), 
                       type = "error")
      return(NULL)
    }
    if (nlevels(df$group) < 2) {
      showNotification(strong("Grouping variable must have at least 2 groups."), 
                       type = "error")
      return(NULL)
    }
    group_sizes <- table(df$group)
    if (any(group_sizes < 2)) {
      showNotification(strong("All groups must have at least 2 values for Levene's test."), 
                       type = "error")
      return(NULL)
    }
    df %>% levene_test(value ~ group)
  })


  # Shapiro result (reactive)

## Independent t-test Shapiro result
  shapiro_result_independent <- function(df) {
    if (all(is.na(df$group))) {
      showNotification(strong("Group column contains only NA. Please select a valid grouping variable."), 
                       type = "error")
      return(NULL)
    }
    if (nlevels(df$group) < 2) {
      showNotification(strong("Grouping variable must have at least 2 groups."), type = "error")
      return(NULL)
    }
    group_sizes <- table(df$group)
    if (any(group_sizes < 3) | any(group_sizes > 5000)) {
      showNotification(strong("All groups must have between 3 and 5000 values for normality testing (Shapiro-Wilk)."), type = "error")
      return(NULL)
    }
    df %>% group_by(group) %>% shapiro_test(value)
  }

## Dependent t-test Shapiro result
  shapiro_result_dependent <- function(df) {
    if (all(is.na(df$group))) {
      showNotification(strong("Group column contains only NA. Please select a valid grouping variable."), type = "error")
      return(NULL)
    }
    if (nlevels(df$group) < 2) {
      showNotification(strong("Grouping variable must have at least 2 groups."), type = "error")
      return(NULL)
    }
    group_levels <- levels(df$group)
    if (length(group_levels) != 2) return(NULL)
    values1 <- df %>% filter(group == group_levels[1]) %>% pull(value)
    values2 <- df %>% filter(group == group_levels[2]) %>% pull(value)
    if (length(values1) != length(values2) || length(values1) < 3) return(NULL)
    diff <- values1 - values2
    if (length(diff) < 3 | length(diff) > 5000) {
      showNotification(strong("Need between 3 and 5000 paired values for normality testing (Shapiro-Wilk)."), type = "error")
      return(NULL)
    }
    shapiro_test(diff)
  }


  ## ANOVA Shapiro result
  shapiro_result_anova <- function(df) {
    if (all(is.na(df$group))) {
      showNotification(strong("Group column contains only NA. Please select a valid grouping variable."), 
                       type = "error")
      return(NULL)
    }
    if (nlevels(df$group) < 2) {
      showNotification(strong("Grouping variable must have at least 2 groups."), type = "error")
      return(NULL)
    }
    group_sizes <- table(df$group)
    if (any(group_sizes < 3) | any(group_sizes > 5000)) {
      showNotification(strong("All groups must have between 3 and 5000 values for normality testing (Shapiro-Wilk)."), type = "error")
      return(NULL)
    }
    df %>% group_by(group) %>% shapiro_test(value)
  }

  shapiro_result <- reactive({
    df <- processed_data()
    if (is.null(df)) return(NULL)
    switch(
      input$test_type,
      "independent_ttest" = shapiro_result_independent(df),
      "dependent_ttest"   = shapiro_result_dependent(df),
      "anova"   = shapiro_result_anova(df),
      # Add more as needed
      NULL
    )
  })


  # Screenshot of the assumption
  observeEvent(input$start_screenshot, {
    shinyscreenshot::screenshot(selector = "#report_content", scale = 8)
  })

  output$show_screenshot_btn <- renderUI({
    # Show only if the report is not empty
    if (!is.null(processed_data())) {
      div(
        id = "screenshot_div",
        #style = "display: none;",  # Hidden by default, shown programmatically
        actionButton("screenshot_btn", "Download Full Report", class = "btn-plot",
                     onclick = "screenshotWithoutDownloadBtns()")
      )
    }
  })
  
  
  # --- Run Statistical Test ---

## Independent t-test
  run_independent_test <- function(df) {
    tryCatch({
      rstatix::t_test(df, value ~ group, paired = FALSE, detailed = TRUE)
    }, error = function(e) data.frame(p = NA))
  }

## Dependent t-test
  run_dependent_test <- function(df) {
    tryCatch({
      rstatix::t_test(df, value ~ group, paired = TRUE, detailed = TRUE)
    }, error = function(e) data.frame(p = NA))
  }

## Mann-Whitney U test
  run_mannwhitney_test <- function(df) {
    ngroups <- nlevels(df$group)
    if (ngroups != 2) {
      showNotification(strong("Mann-Whitney U test requires exactly 2 groups. For more than 2 groups, use Kruskal-Wallis."), type = "error")
      return(data.frame(p = NA))
    }
    tryCatch({
      rstatix::wilcox_test(df, value ~ group, paired = F, detailed = T)
    }, error = function(e) data.frame(p = NA))
  }
  

## Wilcoxon signed-rank test
  run_wilcoxon_signed_test <- function(df) {
    ngroups <- nlevels(df$group)
    if (ngroups != 2) {
      showNotification(strong("Wilcoxon signed-rank test requires exactly 2 groups. For more than 2 groups, use Kruskal-Wallis."), type = "error")
      return(data.frame(p = NA))
    }
    tryCatch({
      rstatix::wilcox_test(df, value ~ group, paired = TRUE, detailed = TRUE)
    }, error = function(e) data.frame(p = NA))
  }

## One-way ANOVA
  run_anova_test <- function(df) {
    tryCatch({
      rstatix::anova_test(df, value ~ group)
    }, error = function(e) data.frame(p = NA))
  }

## Kruskal–Wallis Test
  run_kruskal_test <- function(df) {
    tryCatch({
      rstatix::kruskal_test(df, value ~ group)
    }, error = function(e) data.frame(p = NA))
  }

  # Later: add run_wilcoxon_test, run_anova_test, etc.

 # Post hoc test
  output$posthoc_ui <- renderUI({
    df <- processed_data()
    if (is.null(df)) return(NULL)
    if (!(input$test_type %in% c("anova", "kruskal"))) return(NULL)
    if (!assumptions_met()) return(NULL)

    pval <- if (input$test_type == "anova") {
      run_anova_test(df)$p[1]
    } else {
      run_kruskal_test(df)$p[1]
    }

    if (!is.na(pval) && pval < 0.05) {
      if (input$test_type == "anova") {
        tagList(
          br(),
          h4("Post hoc (Tukey HSD & p-value correction)"),
          selectInput("posthoc_method", "Choose p-value adjustment method or Tukey HSD:",
                      choices = c("Choose" = "", "Bonferroni" = "bonferroni", "Benjamini-Hochberg (BH)" = "BH",
                                  "Benjamini-Yekutieli (BY)" = "BY", "FDR" = "fdr",
                                  "Holm" = "holm", "Hommel" = "hommel", "Tukey HSD" = "tukey")),
          actionButton("run_posthoc", "Run the Selected Option")
        )
      } else { # Kruskal
        tagList(
          br(),
          h4("Dunn Test (Post hoc for Kruskal–Wallis)"),
          selectInput("posthoc_method", "Choose p-value adjustment method:",
                      choices = c("Choose" = "", "Bonferroni" = "bonferroni",
                                  "Benjamini-Hochberg (BH)" = "BH", "Benjamini-Yekutieli (BY)" = "BY",
                                  "FDR" = "fdr", "Holm" = "holm", "Hommel" = "hommel")),
          actionButton("run_posthoc", "Run Dunn test")
        )
      }
    } else {
      NULL
    }
  })


  # Jump to Assumption Tests when 'Check Assumptions' is clicked
  observeEvent(input$check_assumptions, {
    updateTabsetPanel(session, inputId = "cont_tabs", selected = "Assumption Tests")
  })


  assumptions_checked <- reactiveVal(FALSE)

# Extend this to add the new test
  observeEvent(input$run_test, {

    # Use the correct test type values as in your UI
    parametric_tests <- c("independent_ttest", "dependent_ttest", "anova")
    
    # ---- Required Input Checks (before running test) ----
    if (is.null(input$file)) {
      showNotification(strong("Please upload a data file."), type = "error")
      return()
    }
    if (is.null(input$test_type) || input$test_type == "") {
      showNotification(strong("Please select a statistical test."), type = "error")
      return()
    }
    if (is.null(input$value_col) || input$value_col == "") {
      showNotification(strong("Please select a numeric value column."), type = "error")
      return()
    }
    if (is.null(input$group_col) || input$group_col == "") {
      showNotification(strong("Please select a group/condition column."), type = "error")
      return()
    }

    # Check if assumptions must be checked
    if (input$test_type %in% parametric_tests && !assumptions_checked()) {
      showNotification(strong("Please Check the Assumptions first."), type = "error")
      return(NULL)
    }

    # Switch to the test results tab
    updateTabsetPanel(session, inputId = "cont_tabs", selected = "Test Results")

    # Mark test as clicked
    run_test_clicked(Sys.time())

    # Output rendering
    output$test_result_with_square <- renderUI({
      df <- processed_data()
      if (is.null(df)) return(NULL)
      if (input$test_type == "kruskal") {
        ngroups <- nlevels(df$group)
        if (ngroups < 3) {
          showNotification(strong("Kruskal-Wallis requires at least 3 groups. For two groups, use the Wilcoxon or Mann–Whitney test (as appropriate)."), type = "error")
          return(NULL)
        }}
      if (!assumptions_met()) {
        div(style = "background-color: #e0e0e0; color: #222; padding: 14px; border-radius: 5px; font-size: 1.1em; margin-top: 10px;",
            strong("This test is not suitable for your data."),
            br(),
            "Assumptions for this test are not met."
        )
      } else {
        tagList(
          verbatimTextOutput("actual_test_result"),
          stat_square_func(df)
        )
      }
    })
    output$actual_test_result <- renderPrint({
      df <- processed_data()
      switch(
        input$test_type,
        "independent_ttest" = {
          res <- run_independent_test(df)
          res %>% knitr::kable(align = "c", "simple")
        },
        "dependent_ttest"   = {
          res <- run_dependent_test(df)
          res %>% knitr::kable(align = "c", "simple")
        },
        "mannwhitney" = {
          res <- run_mannwhitney_test(df)
          res %>% knitr::kable(align = "c", "simple")
        },
        "wilcoxon_signed" = {
          res <- run_wilcoxon_signed_test(df)
          res %>% knitr::kable(align = "c", "simple")
        },
        "anova" = {
          res <- run_anova_test(df)
          res %>% knitr::kable(align = "c", "simple")
        },
        "kruskal" = {
          res <- run_kruskal_test(df)
          res %>% knitr::kable(align = "c", "simple")
        },
        "chisq" = {
          res <- run_chisq_test(df)
          res %>% knitr::kable(align = "c", "simple")
        },
        "fisher" = {
          res <- run_fisher_test(df)
          res %>% knitr::kable(align = "c", "simple")
        },
        ## add the rest
        NULL
      )
    })
    
  })

  stat_square_func <- function(df) {
    switch(
      input$test_type,
      "independent_ttest" = stat_square_independent(df),
      "dependent_ttest" = stat_square_dependent(df),
      "mannwhitney" = stat_square_mannwhitney(df),
      "wilcoxon_signed" = stat_square_wilcoxon_signed(df),
      "anova" = stat_square_anova(df),
      "kruskal" = stat_square_kruskal(df),
      "chisq" = stat_square_chisq(df),
      "fisher" = stat_square_fisher(df),
      NULL
    )
  }


  # --- Put these right after the above block ---
  observeEvent(input$file,     { run_test_clicked(FALSE) })
  observeEvent(input$test_type, { run_test_clicked(FALSE) })

  # --- Statistical Significance Square ---

## Independent t-test
  stat_square_independent <- function(df) {
    pval <- run_independent_test(df)$p[1]
    if (is.na(pval)) return(NULL)
    div(style = paste0("background-color: ", if (pval < 0.05) "green" else "#B20D00", "; color: white; padding: 10px; border-radius: 5px; margin-top: 10px;"),
        strong(if (pval < 0.05) "Statistically Significant Difference" else "No Statistically Significant Difference"))
  }

## Dependent t-test
  stat_square_dependent <- function(df) {
    pval <- run_dependent_test(df)$p[1]
    if (is.na(pval)) return(NULL)
    div(style = paste0("background-color: ", if (pval < 0.05) "green" else "#B20D00", "; color: white; padding: 10px; border-radius: 5px; margin-top: 10px;"),
        strong(if (pval < 0.05) "Statistically Significant Difference" else "No Statistically Significant Difference"))
  }

## Mann-Whitney U test
  stat_square_mannwhitney <- function(df) {
    pval <- run_mannwhitney_test(df)$p[1]
    if (is.na(pval)) return(NULL)
    div(style = paste0("background-color: ", if (pval < 0.05) "green" else "#B20D00", "; color: white; padding: 10px; border-radius: 5px; margin-top: 10px;"),
        strong(if (pval < 0.05) "Statistically Significant Difference" else "No Statistically Significant Difference"))
  }

## Wilcoxon signed-rank test
  stat_square_wilcoxon_signed <- function(df) {
    pval <- run_wilcoxon_signed_test(df)$p[1]
    if (is.na(pval)) return(NULL)
    div(style = paste0("background-color: ", if (pval < 0.05) "green" else "#B20D00", "; color: white; padding: 10px; border-radius: 5px; margin-top: 10px;"),
        strong(if (pval < 0.05) "Statistically Significant Difference" else "No Statistically Significant Difference"))
  }

## One-way ANOVA
  stat_square_anova <- function(df) {
    pval <- run_anova_test(df)$p[1]
    if (is.na(pval)) return(NULL)
    div(style = paste0("background-color: ", if (pval < 0.05) "green" else "#B20D00",
                       "; color: white; padding: 10px; border-radius: 5px; margin-top: 10px;"),
        strong(if (pval < 0.05) "Statistically Significant Difference" else "No Statistically Significant Difference"))
  }

## Kruskal–Wallis
  stat_square_kruskal <- function(df) {
    pval <- run_kruskal_test(df)$p[1]
    if (is.na(pval)) return(NULL)
    div(style = paste0("background-color: ", if (pval < 0.05) "green" else "#B20D00",
                       "; color: white; padding: 10px; border-radius: 5px; margin-top: 10px;"),
        strong(if (pval < 0.05) "Statistically Significant Difference" else "No Statistically Significant Difference"))
  }


  # Extend it
output$statistical_significance_square <- renderUI({
  if (!run_test_clicked()) return(NULL)
  if (!assumptions_met()) return(NULL)
  df <- processed_data()
  if (is.null(df)) return(NULL)
  switch(
      input$test_type,
      "independent_ttest" = stat_square_independent(df),
      "dependent_ttest" = stat_square_dependent(df),
      "mannwhitney" = stat_square_mannwhitney(df),
      "wilcoxon_signed" = stat_square_wilcoxon_signed(df),
      "anova" = stat_square_anova(df),
      "kruskal" = stat_square_kruskal(df),
      # Add more as needed
      NULL
    )
  })

  # --- Boxplot (independent) ---
  plot_independent_boxplot <- function(df) {
    comparison <- combn(unique(df$group), 2, simplify = FALSE)
    ggplot(df, aes(x = group, y = value, fill = group)) +
      geom_boxplot(alpha = 0.7, width = 0.3, outlier.colour = NA) +
      geom_jitter(width = 0.1, alpha = 0.5, shape = 21, size = 1.3) +
      theme_test() +
      labs(x = "Group", y = "Value") +
      theme(axis.title.y = element_text(face = "bold", size = 14),
            axis.title.x = element_text(face = "bold", size = 14),
            axis.text.y = element_text(hjust = 0.5, vjust = 0.5, colour = "black", size = 12),
            axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1,
                                       colour = "black", size = 12),
            plot.background = element_rect(fill = "white"),
            legend.title = element_text(face = "bold", size = 14),
            legend.text = element_text(size = 12)) +
      theme(legend.position = "none") +
      geom_flat_violin(position = position_nudge(x = 0.2, y = 0), alpha = 0.8, adjust = 0.9, width = 0.5)
  }

  # --- Boxplot (dependant) ---
  plot_dependent_boxplot <- function(df) {
    ggplot(df, aes(x = group, y = value, fill = group)) +
      geom_boxplot(alpha = 0.7, width = 0.3, outlier.colour = NA) +
      geom_jitter(width = 0.1, alpha = 0.5, shape = 21, size = 1.3) +
      theme_test() +
      labs(x = "Group", y = "Value") +
      theme(axis.title.y = element_text(face = "bold", size = 14),
            axis.title.x = element_text(face = "bold", size = 14),
            axis.text.y = element_text(hjust = 0.5, vjust = 0.5, colour = "black", size = 12),
            axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1,
                                       colour = "black", size = 12),
            plot.background = element_rect(fill = "white"),
            legend.title = element_text(face = "bold", size = 14),
            legend.text = element_text(size = 12)) +
      theme(legend.position = "none") +
      geom_flat_violin(position = position_nudge(x = 0.2, y = 0), alpha = 0.8, adjust = 0.9, width = 0.5)
  }

  # --- Boxplot (Mann-Whitney) ---
  plot_mannwhitney_boxplot <- function(df) {
    ggplot(df, aes(x = group, y = value, fill = group)) +
      geom_boxplot(alpha = 0.7, width = 0.3, outlier.colour = NA) +
      geom_jitter(width = 0.1, alpha = 0.5, shape = 21, size = 1.3) +
      theme_test() +
      labs(x = "Group", y = "Value") +
      theme(axis.title.y = element_text(face = "bold", size = 14),
            axis.title.x = element_text(face = "bold", size = 14),
            axis.text.y = element_text(hjust = 0.5, vjust = 0.5, colour = "black", size = 12),
            axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1,
                                       colour = "black", size = 12),
            plot.background = element_rect(fill = "white"),
            legend.title = element_text(face = "bold", size = 14),
            legend.text = element_text(size = 12)) +
      theme(legend.position = "none") +
      geom_flat_violin(position = position_nudge(x = 0.2, y = 0), alpha = 0.8, adjust = 0.9, width = 0.5)
  }

# --- Boxplot (Wilcoxon signed-rank test) ---
  plot_wilcoxon_boxplot <- function(df) {
    ggplot(df, aes(x = group, y = value, fill = group)) +
      geom_boxplot(alpha = 0.7, width = 0.3, outlier.colour = NA) +
      geom_jitter(width = 0.1, alpha = 0.5, shape = 21, size = 1.3) +
      theme_test() +
      labs(x = "Group", y = "Value") +
      theme(axis.title.y = element_text(face = "bold", size = 14),
            axis.title.x = element_text(face = "bold", size = 14),
            axis.text.y = element_text(hjust = 0.5, vjust = 0.5, colour = "black", size = 12),
            axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1,
                                       colour = "black", size = 12),
            plot.background = element_rect(fill = "white"),
            legend.title = element_text(face = "bold", size = 14),
            legend.text = element_text(size = 12)) +
      theme(legend.position = "none") +
      geom_flat_violin(position = position_nudge(x = 0.2, y = 0), alpha = 0.8, adjust = 0.9, width = 0.5)
  }

# --- Boxplot (Anova) ---
  plot_anova_boxplot <- function(df) {
    comparison <- combn(unique(df$group), 2, simplify = FALSE)
    ggplot(df, aes(x = group, y = value, fill = group)) +
      geom_boxplot(alpha = 0.7, width = 0.3, outlier.colour = NA) +
      geom_jitter(width = 0.1, alpha = 0.5, shape = 21, size = 1.3) +
      theme_test() +
      labs(x = "Group", y = "Value") +
      theme(axis.title.y = element_text(face = "bold", size = 14),
            axis.title.x = element_text(face = "bold", size = 14),
            axis.text.y = element_text(hjust = 0.5, vjust = 0.5, colour = "black", size = 12),
            axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1,
                                       colour = "black", size = 12),
            plot.background = element_rect(fill = "white"),
            legend.title = element_text(face = "bold", size = 14),
            legend.text = element_text(size = 12)) +
      theme(legend.position = "none") +
      geom_flat_violin(position = position_nudge(x = 0.2, y = 0), alpha = 0.8, adjust = 0.9, width = 0.5)
  }

  # --- Boxplot (Kruskal) ---
  plot_kruskal_boxplot <- function(df) {
    comparison <- combn(unique(df$group), 2, simplify = FALSE)
    ggplot(df, aes(x = group, y = value, fill = group)) +
      geom_boxplot(alpha = 0.7, width = 0.3, outlier.colour = NA) +
      geom_jitter(width = 0.1, alpha = 0.5, shape = 21, size = 1.3) +
      theme_test() +
      labs(x = "Group", y = "Value") +
      theme(axis.title.y = element_text(face = "bold", size = 14),
            axis.title.x = element_text(face = "bold", size = 14),
            axis.text.y = element_text(hjust = 0.5, vjust = 0.5, colour = "black", size = 12),
            axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1,
                                       colour = "black", size = 12),
            plot.background = element_rect(fill = "white"),
            legend.title = element_text(face = "bold", size = 14),
            legend.text = element_text(size = 12)) +
      theme(legend.position = "none") +
      geom_flat_violin(position = position_nudge(x = 0.2, y = 0), alpha = 0.8, adjust = 0.9, width = 0.5)
  }

  # Now use a switch for easy expansion
  observeEvent(input$plot_boxplot, {
    output$boxplot <- renderPlot({
      df <- processed_data()
      if (is.null(df) || !assumptions_met()) return(NULL)
      switch(
        input$test_type,
        "independent_ttest" = plot_independent_boxplot(df),
        "dependent_ttest"   = plot_dependent_boxplot(df),
        "mannwhitney"   = plot_mannwhitney_boxplot(df),
        "wilcoxon_signed" = plot_wilcoxon_boxplot(df),
        "anova" = plot_anova_boxplot(df),
        "kruskal" = plot_kruskal_boxplot(df),
        NULL
      )
    })
  })

  # --- Download Boxplot ---

## Independent t-test
  plot_independent_boxplot <- function(df) {
    comparison <- combn(unique(df$group), 2, simplify = FALSE)
    ggplot(df, aes(x = group, y = value, fill = group)) +
      geom_boxplot(alpha = 0.7, width = 0.3, outlier.colour = NA) +
      geom_jitter(width = 0.1, alpha = 0.5, shape = 21, size = 1.3) +
      theme_test() +
      labs(x = "Group", y = "Value") +
      theme(axis.title.y = element_text(face = "bold", size = 14),
            axis.title.x = element_text(face = "bold", size = 14),
            axis.text.y = element_text(hjust = 0.5, vjust = 0.5, colour = "black", size = 12),
            axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1,
                                       colour = "black", size = 12),
            plot.background = element_rect(fill = "white"),
            legend.title = element_text(face = "bold", size = 14),
            legend.text = element_text(size = 12)) +
      theme(legend.position = "none") +
      geom_flat_violin(position = position_nudge(x = 0.2, y = 0), alpha = 0.8, adjust = 0.9, width = 0.5)
  }

## Dependent t-test
  plot_dependent_boxplot <- function(df) {
    group_levels <- levels(df$group)
    v1 <- df %>% filter(group == group_levels[1]) %>% pull(value)
    v2 <- df %>% filter(group == group_levels[2]) %>% pull(value)
    n <- min(length(v1), length(v2))
    box_data <- data.frame(
      Condition = rep(c(group_levels[1], group_levels[2]), each = n),
      Value = c(v1[1:n], v2[1:n])
    )
    ggplot(box_data, aes(x = Condition, y = Value, fill = Condition)) +
      geom_boxplot(alpha = 0.7, width = 0.3, outlier.colour = NA) +
      geom_jitter(width = 0.1, alpha = 0.5, shape = 21, size = 1.3) +
      theme_test() +
      labs(x = "Group", y = "Value") +
      theme(axis.title.y = element_text(face = "bold", size = 14),
            axis.title.x = element_text(face = "bold", size = 14),
            axis.text.y = element_text(hjust = 0.5, vjust = 0.5, colour = "black", size = 12),
            axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1,
                                       colour = "black", size = 12),
            plot.background = element_rect(fill = "white"),
            legend.title = element_text(face = "bold", size = 14),
            legend.text = element_text(size = 12)) +
      theme(legend.position = "none") +
      geom_flat_violin(position = position_nudge(x = 0.2, y = 0), alpha = 0.8, adjust = 0.9, width = 0.5)
  }

  ## Mann-Whitney
  plot_mannwhitney_boxplot <- function(df) {
    ggplot(df, aes(x = group, y = value, fill = group)) +
      geom_boxplot(alpha = 0.7, width = 0.3, outlier.colour = NA) +
      geom_jitter(width = 0.1, alpha = 0.5, shape = 21, size = 1.3) +
      theme_test() +
      labs(x = "Group", y = "Value") +
      theme(axis.title.y = element_text(face = "bold", size = 14),
            axis.title.x = element_text(face = "bold", size = 14),
            axis.text.y = element_text(hjust = 0.5, vjust = 0.5, colour = "black", size = 12),
            axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1,
                                       colour = "black", size = 12),
            plot.background = element_rect(fill = "white"),
            legend.title = element_text(face = "bold", size = 14),
            legend.text = element_text(size = 12)) +
      theme(legend.position = "none") +
      geom_flat_violin(position = position_nudge(x = 0.2, y = 0), alpha = 0.8, adjust = 0.9, width = 0.5)
  }

## Wilcoxon signed-rank
  plot_wilcoxon_boxplot <- function(df) {
    ggplot(df, aes(x = group, y = value, fill = group)) +
      geom_boxplot(alpha = 0.7, width = 0.3, outlier.colour = NA) +
      geom_jitter(width = 0.1, alpha = 0.5, shape = 21, size = 1.3) +
      theme_test() +
      labs(x = "Group", y = "Value") +
      theme(axis.title.y = element_text(face = "bold", size = 14),
            axis.title.x = element_text(face = "bold", size = 14),
            axis.text.y = element_text(hjust = 0.5, vjust = 0.5, colour = "black", size = 12),
            axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1,
                                       colour = "black", size = 12),
            plot.background = element_rect(fill = "white"),
            legend.title = element_text(face = "bold", size = 14),
            legend.text = element_text(size = 12)) +
      theme(legend.position = "none") +
      geom_flat_violin(position = position_nudge(x = 0.2, y = 0), alpha = 0.8, adjust = 0.9, width = 0.5)
  }

## One-way ANOVA
  plot_anova_boxplot <- function(df) {
    comparison <- combn(unique(df$group), 2, simplify = FALSE)
    ggplot(df, aes(x = group, y = value, fill = group)) +
      geom_boxplot(alpha = 0.7, width = 0.3, outlier.colour = NA) +
      geom_jitter(width = 0.1, alpha = 0.5, shape = 21, size = 1.3) +
      theme_test() +
      labs(x = "", y = "Value") +
      theme(axis.title.y = element_text(face = "bold", size = 14),
            axis.title.x = element_text(face = "bold", size = 14),
            axis.text.y = element_text(hjust = 0.5, vjust = 0.5, colour = "black", size = 12),
            axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1,
                                       colour = "black", size = 12),
            plot.background = element_rect(fill = "white"),
            legend.title = element_text(face = "bold", size = 14),
            legend.text = element_text(size = 12)) +
      theme(legend.position = "none") +
      geom_flat_violin(position = position_nudge(x = 0.2, y = 0), alpha = 0.8, adjust = 0.9, width = 0.5)
  }

# --- Kruskal-Wallis ---
  plot_kruskal_boxplot <- function(df) {
    comparison <- combn(unique(df$group), 2, simplify = FALSE)
    ggplot(df, aes(x = group, y = value, fill = group)) +
      geom_boxplot(alpha = 0.7, width = 0.3, outlier.colour = NA) +
      geom_jitter(width = 0.1, alpha = 0.5, shape = 21, size = 1.3) +
      theme_test() +
      labs(x = "Group", y = "Value") +
      theme(axis.title.y = element_text(face = "bold", size = 14),
            axis.title.x = element_text(face = "bold", size = 14),
            axis.text.y = element_text(hjust = 0.5, vjust = 0.5, colour = "black", size = 12),
            axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1,
                                       colour = "black", size = 12),
            plot.background = element_rect(fill = "white"),
            legend.title = element_text(face = "bold", size = 14),
            legend.text = element_text(size = 12)) +
      theme(legend.position = "none") +
      geom_flat_violin(position = position_nudge(x = 0.2, y = 0), alpha = 0.8, adjust = 0.9, width = 0.5)
  }


  output$download_boxplot <- downloadHandler(
    filename = function() {
      paste("boxplot_", Sys.Date(), ".png", sep = "")
    },
    content = function(file) {
      df <- processed_data()
      # ---- THIS CHECK IS CRUCIAL ----
      if (is.null(df) || !assumptions_met()) return(NULL)
      p <- switch(
        input$test_type,
        "independent_ttest" = plot_independent_boxplot(df),
        "dependent_ttest"   = plot_dependent_boxplot(df),
        "mannwhitney"   = plot_mannwhitney_boxplot(df),
        "wilcoxon_signed"   = plot_wilcoxon_boxplot(df),
        "anova"   = plot_anova_boxplot(df),
        "kruskal"   = plot_kruskal_boxplot(df),
        NULL
      )
      if (is.null(p)) return(NULL)
      ggsave(file, plot = p, width = 8, height = 4, dpi = 600, bg = "white")
    }
  )
############################################################################################################
############################################################################################################
############################################################################################################
############################################################################################################
############################################################################################################
############################################################################################################
############################################################################################################
############################################################################################################

# Fisher and Chi-square

  ## Read the data and update timepoint dropdown
  fisher_data <- reactive({
    req(input$file_fisher)
    readr::read_csv(input$file_fisher$datapath, show_col_types = F)
  })

  run_fisher_clicked <- reactiveVal(FALSE)

  run_fisher_clicked <- reactiveVal(FALSE)
  observeEvent(list(input$file_fisher, input$cat1, input$cat2, input$test_type_fisher), {
    run_fisher_clicked(FALSE)
  })
  
  # UI for selecting first categorical variable
  output$cat1_ui <- renderUI({
    df <- fisher_data()
    cat_vars <- names(df)[sapply(df, function(col) is.character(col) || is.factor(col))]
    
    selectInput("cat1", "Select first categorical variable:",
                choices = c("Select variable" = "", cat_vars),
                selected = "")
  })
  
  # UI for selecting second categorical variable, excluding the first
  output$cat2_ui <- renderUI({
    df <- fisher_data()
    cat_vars <- names(df)[sapply(df, function(col) is.character(col) || is.factor(col))]
    
    selectInput("cat2", "Select second categorical variable:",
                choices = c("Select variable" = "", cat_vars),
                selected = "")
  })
  

  output$fisher_timepoint_ui <- renderUI({
    df <- fisher_data()
    if ("timepoint" %in% names(df)) {
      selectInput("fisher_timepoint",
                  label = "Select timepoint (for longitudinal data):",
                  choices = c("Select timepoint" = "", unique(df$timepoint)),
                  selected = ""
      )
    }
  })

  # Update the categorical variable selectors when data is uploaded or timepoint selected
  observe({
    df <- fisher_data()
    if (!is.null(input$fisher_timepoint) && input$fisher_timepoint != "" && "timepoint" %in% names(df)) {
      df <- dplyr::filter(df, timepoint == input$fisher_timepoint)
    }
    is_categorical <- function(x) is.factor(x) || is.character(x)
    cat_vars <- names(df)[sapply(df, is_categorical)]
    cat_vars <- setdiff(cat_vars, c("timepoint", "sample_id"))
    updateSelectInput(session, "cat1", choices = c("Select variable" = "", cat_vars),
                      label = "Select first categorical variable:", selected = "")
    updateSelectInput(session, "cat2", choices = c("Select variable" = "", cat_vars),
                      label = "Select second categorical variable:", selected = "")
  })

  reset_outputs <- function() {
    output$fisher_chisq_result <- renderPrint({ "The server is ready." })
    output$posthoc_result_fisher <- renderPrint({ "The server is ready." })
  }
  
  observeEvent(input$cat1, {
    df <- fisher_data()
    cat_vars <- names(df)[sapply(df, function(col) is.character(col) || is.factor(col))]
    remaining_vars <- setdiff(cat_vars, input$cat1)
    
    updateSelectInput(session, "cat2",
                      choices = c("Select variable" = "", remaining_vars),
                      selected = "")
  })

  observeEvent(input$file_fisher, reset_outputs())
  observeEvent(input$test_type_fisher, reset_outputs())
  observeEvent(input$cat1, reset_outputs())
  observeEvent(input$cat2, reset_outputs())

  ## Run the test when button clicked
  observeEvent(input$run_fisher, {
    # ---- Required Input Checks ----
    if (is.null(input$file_fisher)) {
      showNotification(strong("Please upload a data file."), type = "error")
      return()
    }
    if (is.null(input$cat1) || input$cat1 == "") {
      showNotification(strong("Please select the first categorical variable."), type = "error")
      return()
    }
    if (is.null(input$cat2) || input$cat2 == "") {
      showNotification(strong("Please select the second categorical variable."), type = "error")
      return()
    }
    if (is.null(input$test_type_fisher) || input$test_type_fisher == "") {
      showNotification(strong("Please choose a test (Fisher or Chi-square) before running."), type = "error")
      return()
    }
    run_fisher_clicked(TRUE)
    req(fisher_data(), input$cat1, input$cat2, input$test_type_fisher)
    df <- fisher_data()
    if (!is.null(input$fisher_timepoint) && input$fisher_timepoint != "" && "timepoint" %in% names(df)) {
      df <- dplyr::filter(df, timepoint == input$fisher_timepoint)
    }
    
    if (input$cat1 == "" || input$cat2 == "") {
      showNotification(strong("Please select both categorical variables."), type = "error")
      return()
    }


    # --- Force categorical, remove NAs, drop unused levels ---
    df[[input$cat1]] <- as.factor(df[[input$cat1]])
    df[[input$cat2]] <- as.factor(df[[input$cat2]])
    df <- df[!is.na(df[[input$cat1]]) & !is.na(df[[input$cat2]]), ]
    df[[input$cat1]] <- droplevels(df[[input$cat1]])
    df[[input$cat2]] <- droplevels(df[[input$cat2]])

    if (!is.factor(df[[input$cat1]]) && !is.character(df[[input$cat1]])) {
      showNotification(strong("First variable must be categorical. Please select a categorical variable."), 
                       type = "error")
      return()
    }
    if (!is.factor(df[[input$cat2]]) && !is.character(df[[input$cat2]])) {
      showNotification(strong("Second variable must be categorical. Please select a categorical variable."), 
                       type = "error")
      return()
    }


    output$fisher_chisq_result <- renderPrint({
      df <- fisher_data()
      if (!is.null(input$fisher_timepoint) && input$fisher_timepoint != "" && "timepoint" %in% names(df)) {
        df <- dplyr::filter(df, timepoint == input$fisher_timepoint)
      }
      
      if (nrow(df) == 0) {
        return(invisible(NULL)) # Prevent errors if no data after filtering
      }
      tab <- df %>%
        dplyr::select(.data[[input$cat1]], .data[[input$cat2]]) %>%
        tidyr::drop_na() %>%
        table()
      
      # Special check for one-group-per-variable (degenerate case)
      if (any(dim(tab) < 2)) {
        shiny::showModal(modalDialog(
          title = div(icon("exclamation-triangle", lib = "font-awesome"), "Invalid data for Fisher's Exact Test"),
          div(
            style = "background-color:#f8d7da; color:#721c24; padding:14px; border:1px solid #f5c6cb; border-radius:5px; margin-bottom:12px;",
            icon("exclamation-circle", lib = "font-awesome"),
            strong(" Error: "),
            "Fisher's Exact Test requires at least two groups for each variable. Your data contains only one group in one or both variables. ",
            "Please provide a dataset with at least two distinct groups for each variable to use Fisher's Exact Test or Chi-square."
          ),
          easyClose = TRUE,
          footer = NULL
        ))
        cat("Cannot run test: both variables must have at least two groups each.")
        return(invisible(NULL))
      }
      if (any(dim(tab) < 2)) {
        shiny::showModal(
          modalDialog(
            title = div(icon("exclamation-triangle", lib = "font-awesome"), "Invalid data for Fisher's Exact Test or Chi-square"),
            div(
              style = "background-color:#f8d7da; color:#721c24; padding:14px; border:1px solid #f5c6cb; border-radius:5px; margin-bottom:12px;",
              icon("exclamation-circle", lib = "font-awesome"),
              strong(" Error: "),
              "Test requires at least two groups for both variables. Your data contains only one group in one or both variables. ",
              "Please provide a dataset with at least two distinct groups for each variable."
            ),
            easyClose = TRUE,
            footer = NULL
          )
        )
        # ALSO CLEAR OTHER OUTPUTS
        output$fisher_chisq_square <- renderUI({ NULL })
        output$posthoc_result_fisher <- renderPrint({ NULL })
        return(invisible(NULL))
      }

      tryCatch({
        if (input$test_type_fisher == "chisq") {
          test <- chisq.test(tab)
          exp_counts <- test$expected
          
          # Store warning if expected count < 5
          warn_msg <- NULL
          if (any(exp_counts < 5)) {
            warn_msg <<- div(
              style = "background-color:#fff3cd; color:#856404; padding:14px; border:1px solid #ffeeba; border-radius:5px; margin-bottom:12px;",
              icon("exclamation-triangle", lib = "font-awesome"),
              strong(" Warning: "),
              "Some expected cell counts are less than 5. Consider using Fisher's exact test instead of Chi-square."
            )
          } else {
            warn_msg <<- NULL
          }
          
          knitr::kable(rstatix::chisq_test(tab), align = "c", "simple")
        } else {
          knitr::kable(rstatix::fisher_test(tab, detailed = T), align = "c", "simple")
        }
      }, error = function(e) {
        showNotification(paste("Error:", e$message), type = "error")
        cat("Test could not be run. Check your data and selections.")
      })
    })



    stat_square_chisq <- function(df) {
      res <- run_chisq_test(df)
      pval <- res$p[1]
      if (is.na(pval)) return(NULL)
      div(
        style = paste0(
          "background-color: ", if (pval < 0.05) "green" else "#B20D00",
          "; color: white; padding: 10px; border-radius: 5px; margin-top: 10px;"
        ),
        strong(if (pval < 0.05) "Statistically Significant Difference" else "No Statistically Significant Difference")
      )
    }

    stat_square_fisher <- function(df) {
      res <- run_fisher_test(df)
      pval <- res$p[1]
      if (is.na(pval)) return(NULL)
      div(
        style = paste0(
          "background-color: ", if (pval < 0.05) "green" else "#B20D00",
          "; color: white; padding: 10px; border-radius: 5px; margin-top: 10px;"
        ),
        strong(if (pval < 0.05) "Statistically Significant Difference" else "No Statistically Significant Difference")
      )
    }


    # Handle post hoc
    tab <- df %>%
      dplyr::select(.data[[input$cat1]], .data[[input$cat2]]) %>%
      table()

    output$posthoc_result_fisher <- renderPrint({
      if (!run_fisher_clicked()) return(NULL)
      tab <- df %>%
        dplyr::select(.data[[input$cat1]], .data[[input$cat2]]) %>%
        table()
      if (any(dim(tab) < 2)) return(invisible(NULL))
      

      count1 <- nlevels(droplevels(df[[input$cat1]]))
      count2 <- nlevels(droplevels(df[[input$cat2]]))
      more_than_2 <- (count1 > 2 | count2 > 2)
      pval <- if (input$test_type_fisher == "chisq") {
        rstatix::chisq_test(tab)$p[1]
      } else {
        rstatix::fisher_test(tab)$p[1]
      }

      if (!more_than_2) {
        return(invisible(NULL)) # Show nothing
      } else if (is.na(pval) || pval >= 0.05) {
        return(invisible(NULL)) # Also show nothing here, since UI already tells user why
      } else if (input$posthoc_method_fisher == "" || is.null(input$posthoc_method_fisher)) {
        cat("Select a p-value adjustment method to view post hoc pairwise comparisons.")
      } else {
        # test is significant, more than 2 groups, and method is selected
        p_adj_method <- input$posthoc_method_fisher
        if (input$test_type_fisher == "chisq") {
          res <- tryCatch(
            rstatix::pairwise_prop_test(tab, p.adjust.method = p_adj_method),
            error = function(e) NULL
          )
        } else {
          res <- tryCatch(
            rstatix::pairwise_fisher_test(tab, p.adjust.method = p_adj_method),
            error = function(e) NULL
          )
        }
        if (!is.null(res) && nrow(res) > 0) {
          knitr::kable(res, align = "c", "simple")
        } else {
          cat("Could not compute pairwise post hoc test. Check your data for missing values or errors.")
        }
      }
      
    })

  
    output$posthoc_method_ui <- renderUI({
      req(run_fisher_clicked(), input$cat1, input$cat2, input$test_type_fisher)
      df <- fisher_data()
      if (!is.null(input$fisher_timepoint) && input$fisher_timepoint != "" && "timepoint" %in% names(df)) {
        df <- dplyr::filter(df, timepoint == input$fisher_timepoint)
      }
      tab <- tryCatch({
        df %>%
          dplyr::select(.data[[input$cat1]], .data[[input$cat2]]) %>%
          tidyr::drop_na() %>%
          table()
      }, error = function(e) NULL)
      if (is.null(tab)) return(NULL)
      count1 <- nlevels(droplevels(as.factor(df[[input$cat1]])))
      count2 <- nlevels(droplevels(as.factor(df[[input$cat2]])))
      more_than_2 <- (count1 > 2 | count2 > 2)
      pval <- tryCatch({
        if (input$test_type_fisher == "chisq") {
          rstatix::chisq_test(tab)$p[1]
        } else {
          rstatix::fisher_test(tab)$p[1]
        }
      }, error = function(e) NA_real_)
      if (!more_than_2) {
        return(NULL)   # Do not show anything
      } else if (is.na(pval) || pval >= 0.05) {
        return(tags$div(
          style = "background-color:#fff3cd; color:#856404; padding:14px; border:1px solid #ffeeba; border-radius:5px; margin-bottom:12px;",
          strong("Post hoc pairwise comparisons are only available if the test was significant.")
        ))
      } else {
        return(selectInput("posthoc_method_fisher", strong("Choose p-value adjustment method:"),
                           choices = c("Choose Methods" = "",
                                       "Bonferroni" = "bonferroni",
                                       "Benjamini-Hochberg (BH)" = "BH",
                                       "Benjamini-Yekutieli (BY)" = "BY",
                                       "FDR" = "fdr",
                                       "Holm" = "holm",
                                       "Hommel" = "hommel"),
                           selected = input$posthoc_method_fisher
        ))
      }
    })
    
    
    

  })

  # Reset the plot when categorical variables change
  observeEvent({input$cat1; input$cat2}, {
    output$fisher_plot <- renderPlot({ NULL })
  })

  stat_square_chisq <- function(tab) {
    if (any(dim(tab) < 2)) return(NULL)
    res <- rstatix::chisq_test(tab)
    pval <- res$p[1]
    if (is.na(pval)) return(NULL)
    div(
      style = paste0(
        "background-color: ", if (pval < 0.05) "green" else "#B20D00",
        "; color: white; padding: 10px; border-radius: 5px; margin-top: 10px;"
      ),
      strong(if (pval < 0.05) "Statistically Significant Difference" else "No Statistically Significant Difference")
    )
  }

  stat_square_fisher <- function(tab) {
    if (any(dim(tab) < 2)) return(NULL)
    res <- rstatix::fisher_test(tab)
    pval <- res$p[1]
    if (is.na(pval)) return(NULL)
    div(
      style = paste0(
        "background-color: ", if (pval < 0.05) "green" else "#B20D00",
        "; color: white; padding: 10px; border-radius: 5px; margin-top: 10px;"
      ),
      strong(if (pval < 0.05) "Statistically Significant Difference" else "No Statistically Significant Difference")
    )
  }

  output$fisher_chisq_square <- renderUI({
    if (!run_fisher_clicked()) return(NULL)

    if (!run_fisher_clicked()) return(NULL)
    req(fisher_data(), input$cat1, input$cat2, input$test_type_fisher)
    df <- fisher_data()
    # Filter by timepoint if needed
    if (!is.null(input$fisher_timepoint) && input$fisher_timepoint != "" && "timepoint" %in% names(df)) {
      df <- dplyr::filter(df, timepoint == input$fisher_timepoint)
    }
    
    df[[input$cat1]] <- as.factor(df[[input$cat1]])
    df[[input$cat2]] <- as.factor(df[[input$cat2]])
    tab <- df %>%
      dplyr::select(.data[[input$cat1]], .data[[input$cat2]]) %>%
      tidyr::drop_na() %>%
      table()
    if (any(dim(tab) < 2)) return(NULL)
    
    if (input$test_type_fisher == "chisq") {
      stat_square_chisq(tab)
    } else {
      stat_square_fisher(tab)
    }
  })

  # Hide download button
  shinyjs::hide("download_fisher_plot")
  
 ## plotting for Fisher or Chi square
  observeEvent(input$plot_fisher, {
    if (is.null(input$file_fisher)) {
      showNotification(strong("Please upload a data file."), type = "error")
      return()
    }
    if (is.null(input$cat1) || input$cat1 == "") {
      showNotification(strong("Please select the first categorical variable."), type = "error")
      return()
    }
    if (is.null(input$cat2) || input$cat2 == "") {
      showNotification(strong("Please select the second categorical variable."), type = "error")
      return()
    }

    req(fisher_data(), input$cat1, input$cat2)
    df <- fisher_data()
    if (!is.null(input$fisher_timepoint) && input$fisher_timepoint != "" && "timepoint" %in% names(df)) {
      df <- dplyr::filter(df, timepoint == input$fisher_timepoint)
    }
    
    plot_df <- df %>%
      dplyr::select(.data[[input$cat1]], .data[[input$cat2]]) %>%
      dplyr::group_by(.data[[input$cat1]], .data[[input$cat2]]) %>%
      dplyr::summarise(n = dplyr::n(), .groups = "drop") %>%
      dplyr::group_by(.data[[input$cat1]]) %>%
      dplyr::mutate(freq = n / sum(n) * 100) %>%
      dplyr::ungroup()

    output$fisher_plot <- renderPlot({
      ggplot2::ggplot(
        plot_df,
        ggplot2::aes(
          x = .data[[input$cat1]],
          y = freq,
          fill = .data[[input$cat2]]
        )
      ) +
        ggplot2::geom_bar(stat = "identity", col = "black") +
        ggplot2::theme_test() +
        ggplot2::xlab("") +
        ggplot2::ylab("Proportion") +
        theme(axis.text.x = element_text(size = 12, angle = 45,vjust = 1, hjust = 1, colour = "black")) +
        theme(axis.text.y = element_text(size = 12, colour = "black")) +
        theme(legend.text=element_text(size=12))
    })
    # Show download button after plot is made
    shinyjs::show("download_fisher_plot")
  })

# If the user changes variables or uploads a new file, hide the button again
  observeEvent(list(input$file_fisher, input$cat1, input$cat2), {
    shinyjs::hide("download_fisher_plot")
    output$fisher_plot <- renderPlot({ NULL }) # optional: clear plot
  })
  
  
  
  ## Download for Fisher or Chi square
  output$download_fisher_plot <- downloadHandler(
    filename = function() {
      paste("Perc_", Sys.Date(), ".png", sep = "")
    },
    content = function(file) {
      df <- fisher_data()
      if (!is.null(input$fisher_timepoint) && input$fisher_timepoint != "" && "timepoint" %in% names(df)) {
        df <- dplyr::filter(df, timepoint == input$fisher_timepoint)
      }
      

      plot_df <- df %>%
        dplyr::select(.data[[input$cat1]], .data[[input$cat2]]) %>%
        dplyr::group_by(.data[[input$cat1]], .data[[input$cat2]]) %>%
        dplyr::summarise(n = dplyr::n(), .groups = "drop") %>%
        dplyr::group_by(.data[[input$cat1]]) %>%
        dplyr::mutate(freq = n / sum(n) * 100) %>%
        dplyr::ungroup()

      n_cats <- length(unique(plot_df[[input$cat1]]))
      n_fill <- length(unique(plot_df[[input$cat2]]))

      # Width grows with x categories, legend width grows with fill levels
      plot_width <- max(6, n_cats * 0.5 + ceiling(n_fill / 10) * 1.5)
      plot_height <- max(4, n_fill * 0.2 + 4)

      p <- ggplot2::ggplot(
        plot_df,
        ggplot2::aes(x = .data[[input$cat1]], y = freq, fill = .data[[input$cat2]])
      ) +
        ggplot2::geom_bar(stat = "identity", col = "black") +
        ggplot2::theme_test() +
        ggplot2::xlab("") +
        ggplot2::ylab("Proportion") +
        ggplot2::theme(
          axis.text.x = ggplot2::element_text(size = 12, angle = 45, vjust = 1, hjust = 1, colour = "black"),
          axis.text.y = ggplot2::element_text(size = 12, colour = "black"),
          legend.text = ggplot2::element_text(size = 12)
        )

      ggplot2::ggsave(file, plot = p, width = plot_width, height = plot_height, dpi = 600, bg = "white")
    }
  )

  output$chi_fisher_warning <- renderUI({
    req(fisher_data(), input$cat1, input$cat2)
    if (input$cat1 == "" || input$cat2 == "") return(NULL)
    
    df <- fisher_data()
    if (!is.null(input$fisher_timepoint) && input$fisher_timepoint != "" && "timepoint" %in% names(df)) {
      df <- dplyr::filter(df, timepoint == input$fisher_timepoint)
    }
    
    if (nrow(df) == 0 || !(input$cat1 %in% names(df)) || !(input$cat2 %in% names(df))) return(NULL)
    
    tab <- tryCatch({
      df %>%
        dplyr::select(.data[[input$cat1]], .data[[input$cat2]]) %>%
        tidyr::drop_na() %>%
        table()
    }, error = function(e) NULL)
    
    if (is.null(tab) || any(dim(tab) == 0)) return(NULL)
    
    if (input$test_type_fisher == "chisq") {
      exp_counts <- suppressWarnings(tryCatch(chisq.test(tab)$expected, error = function(e) NULL))
      if (!is.null(exp_counts) && any(exp_counts < 5)) {
        return(div(
          style = "background-color:#fff3cd; color:#856404; padding:14px; border:1px solid #ffeeba; border-radius:5px; margin-bottom:12px;",
          icon("exclamation-triangle", lib = "font-awesome"),
          strong("Warning: "),
          "Some expected frequencies < 5. Chi-squared approximation may be invalid. Consider using Fisher's Exact Test instead."
        ))
      }
    }
    
    return(NULL)
  })
  
############################################################################################################
############################################################################################################
############################################################################################################
############################################################################################################
############################################################################################################
############################################################################################################
############################################################################################################
############################################################################################################

# Correlation analysis

  observe({
    session$onFlushed(function() {
      session$sendCustomMessage("reinit-tooltips", list())
    }, once = FALSE)
  })


# Data Loading & Numeric Feature Detection

  safe_shapiro_pval <- function(x) {
    !is.null(x) && !is.null(x$p.value) && is.numeric(x$p.value) && !is.na(x$p.value)
  }

  # Automatically switch to “Test Results” tab when Run is clicked
  observeEvent(input$cor_run, {
    # Explicit input checks
    if (is.null(input$cor_file)) {
      showNotification(strong("Please upload a data file."), type = "error")
      return()
    }
    if (is.null(input$cor_method) || input$cor_method == "") {
      showNotification(strong("Please choose the test."), type = "error")
      return()
    }
    
    updateTabsetPanel(session, inputId = "cor_tabs", selected = "Test Results")
  })

  # Automatically switch to “Assumption Tests” tab when Check Assumptions is clicked
  observeEvent(input$cor_check_assumptions, {
    updateTabsetPanel(session, inputId = "cor_tabs", selected = "Assumption Tests")
  })


  ## --- Correlation Data Loader ---
  cor_data <- reactive({
    req(input$cor_file)
    tryCatch({
      readr::read_csv(input$cor_file$datapath, show_col_types = F)
    }, error = function(e) {
      showNotification(paste("Error reading file:", e$message), type = "error")
      NULL
    })
  })
  
  observeEvent(cor_data(), {
    df <- cor_data()
    req(df)
    n_feat <- ncol(df) - 1 # adjust if you have a sample/ID column; otherwise, just ncol(df)
    if (n_feat > 100) {
      output$cor_feature_warning_msg <- renderUI({
        div(
          style = "background-color:#fff3cd; color:#856404; padding:14px; border:1px solid #ffeeba; border-radius:5px; margin-bottom:12px;",
          icon("exclamation-triangle", lib = "font-awesome"),
          strong(" Warning:"),
          tags$ul(
            tags$li(
              paste0("Your data has ", n_feat, " features. High feature counts and sparse data (many zeros) can make correlation analysis slow or fail.")
            ),
            tags$li("Use the prevalence slider to filter out low-prevalence features and reduce the feature count to 100 or fewer before clicking 'Run Correlation'."),
            tags$li("Only the top 100 features will be included."),
            tags$li("Downloading the full correlation matrix/table (100 features) may take 10–30 seconds. Please wait after clicking the download button.")
          )
        )
      })
    } else {
      output$cor_feature_warning_msg <- renderUI({ NULL })
    }
  })
  
  

  ## --- Detect Numeric Features, Exclude Sample ID ---
  cor_numeric_features <- reactive({
    df <- cor_data()
    if (is.null(df)) return(character(0))
    possible_id <- names(df)[tolower(names(df)) %in% c("sample_id", "id", "subject_id")]
    num_cols <- names(df)[sapply(df, is.numeric)]
    setdiff(num_cols, possible_id)
  })


  ## --- Feature Selection UI and Select All Button ---
  output$cor_feature_selector <- renderUI({
    num_cols <- cor_numeric_features()
    if (length(num_cols) == 0) return(NULL)


    # Pre-select only the first two numeric columns
    selectizeInput(
      "cor_features",
      "Select features (variables) for correlation:",
      choices = num_cols,
      selected = num_cols[seq_len(min(2, length(num_cols)))],
      multiple = TRUE,
      options = list(maxItems = 100)
    )
  })

  ## --- "Select All" Button Logic ---
  # observeEvent(input$cor_select_all, {
  #   num_cols <- cor_numeric_features()
  #   updateSelectInput(session, "cor_features", selected = num_cols)
  # })

  observeEvent(input$cor_select_all, {
    num_cols <- cor_numeric_features()

    if (input$cor_select_all) {
      # If checkbox is ticked, select all
      updateSelectInput(session, "cor_features", selected = num_cols)
    } else {
      # If checkbox is unticked, reset to default (first 2)
      updateSelectInput(session, "cor_features", selected = num_cols[seq_len(min(2, length(num_cols)))])
    }
  })

  # Data Preprocessing For Correlation

  ## --- Preprocessed correlation data based on selected features ---
  cor_selected_data <- reactive({
    req(cor_data(), input$cor_features)
    df <- cor_data()
    # Remove sample ID columns if present
    possible_id <- names(df)[tolower(names(df)) %in% c("sample_id", "id", "subject_id")]
    if (length(possible_id) > 0) {
      df <- df %>% dplyr::select(-dplyr::all_of(possible_id))
    }
    # Subset to selected features
    df <- df %>% dplyr::select(dplyr::all_of(input$cor_features))

    # Optional prevalence filter
    if (!is.null(input$cor_prev_filter) && input$cor_prev_filter > 0) {
      keep <- sapply(df, function(x) mean(x > 0, na.rm = TRUE) >= input$cor_prev_filter / 100)
      df <- df[, keep, drop = FALSE]
    }

    # Remove features with all NA or zero variance
    df <- df[, sapply(df, function(x) !all(is.na(x)) && stats::sd(x, na.rm = TRUE) > 0), drop = FALSE]
    df
  })

  # --- CLR transformation (optional) ---
  cor_clr_data <- reactive({
    df <- cor_selected_data()
    if (is.null(df)) return(NULL)
    if (isTRUE(input$cor_do_clr) && ncol(df) > 1) {

      # Only numeric, and replace zeros
      df_num <- df %>%
        dplyr::select(where(is.numeric)) %>%
        mutate(across(everything(), ~replace(.x, .x == 0, 0.0001)))

      # Make sure no negative/zero values remain
      if (any(df_num <= 0, na.rm = TRUE)) {
        showNotification(strong("CLR: All values must be positive."), type = "error")
        return(NULL)
      }
      df_clr <- compositions::clr(as.matrix(df_num)) %>%
        as.data.frame()
      colnames(df_clr) <- colnames(df_num)
      df_clr  # return CLR'd dataframe
    } else {
      df
    }
  })

  ## CLR warning
  output$cor_clr_warning <- renderUI({
    req(input$cor_file)
    div(
      style = "font-size: 14px; color: #c0392b; margin-top: -17px; margin-bottom: 10px;",
      icon("info-circle", lib = "font-awesome"),
      strong("For compositional data (e.g., microbiome or -omics), apply CLR transformation to reduce spurious correlations.")
    )
  })


  # Enable/disable the assumption check button:
  observe({
    # Only enable for Pearson & when exactly 2 features are selected
    if (input$cor_method == "pearson" && length(input$cor_features) == 2) {
      shinyjs::enable("cor_check_assumptions")
    } else {
      shinyjs::disable("cor_check_assumptions")
    }
  })

  observeEvent(input$cor_run, {
    if (input$cor_method == "pearson" && length(input$cor_features) > 2) {
      showModal(modalDialog(
        div(
          style = "background-color: #fff3cd; color: #856404; padding: 14px; border: 1px solid #ffeeba; border-radius: 5px; font-size: 1.05em; margin-top: 10px;",
          icon("exclamation-triangle", lib = "font-awesome"),
          strong(" Note: "),
          "Pearson assumptions have only been tested for 2 variables. Assumptions for all pairwise comparisons have not been checked. Proceed with caution."
        ),
        easyClose = TRUE
      ))
    }
  })


  # Info buttons for assumptions:
  cor_assumption_info <- list(
    linearity = "Check if the relationship between variables is linear.",
    normality = "Check if both variables are normally distributed.",
    bivariate_normality = "Check if data are bivariate normal (both together).",
    outliers = "Identify data points that are far from the regression line.",
    homoscedasticity = "Test if variance of residuals is constant across the range."
  )

  # Run assumption checks when button is clicked
  perf_het_val <- reactiveVal(NULL)
  scatter_plot_val <- reactiveVal(NULL)
  shap1_val <- reactiveVal(NULL)
  shap2_val <- reactiveVal(NULL)
  mvn_p_val <- reactiveVal(NULL)
  mvn_ok_val <- reactiveVal(NULL)
  car_outliers_val <- reactiveVal(NULL)


  observeEvent(input$cor_check_assumptions, {
    req(input$cor_features, input$cor_method == "pearson", length(input$cor_features) == 2)
    df <- cor_clr_data()
    if (is.null(df)) return(NULL)
    v1 <- df[[input$cor_features[1]]]
    v2 <- df[[input$cor_features[2]]]

    # --- Linearity plot
    scatter_plot <- make_scatter_plot(v1, v2, input$cor_features[1], input$cor_features[2])
    scatter_plot_val(scatter_plot)


    # --- Normality tests (Shapiro)
    shap1 <- tryCatch(shapiro.test(v1), error = function(e) NULL)
    shap1_val(shap1)
    shap2 <- tryCatch(shapiro.test(v2), error = function(e) NULL)
    shap2_val(shap2)


    # --- Bivariate normality using Henze-Zirkler test
    df2 <- df %>%
      dplyr::select(all_of(input$cor_features)) %>%
      na.omit() %>%
      as.data.frame()

    if (nrow(df2) < 3 || ncol(df2) != 2) {
      mvn_res <- "Not enough data or not exactly 2 variables for bivariate normality test."
      mvn_p <- NA
      mvn_ok <- FALSE
    } else {
      hz_res <- tryCatch({
        MVN::hz(df2)
      }, error = function(e) NULL)
      if (!is.null(hz_res) && is.data.frame(hz_res) && "p.value" %in% colnames(hz_res)) {
        mvn_p <- as.numeric(hz_res$p.value)[1]
        mvn_ok <- !is.na(mvn_p) && mvn_p > 0.05
      } else {
        mvn_p <- NA
        mvn_ok <- FALSE
      }
    }
    mvn_p_val(mvn_p)
    mvn_ok_val(mvn_ok)


    # --- Outliers (car::outlierTest)
    lm_model <- lm(v2 ~ v1)
    car_outliers <- tryCatch({
      outlierTest(lm_model)
    }, error = function(e) NULL)
    car_outliers_val(car_outliers)

    # --- Homoscedasticity
    perf_het <- tryCatch({
      performance::check_heteroscedasticity(lm_model)
    }, error = function(e) NULL)
    perf_het_val(perf_het)

    # --- Results UI
    output$cor_assumption_content <- renderUI({
      req(input$cor_features)
      if (input$cor_method != "pearson") {
        return(div(style = "color: #333; background-color:#f5f5f5; margin-top:12px;",
                   strong("Assumption checks only apply for Pearson correlation.")))
      }
      # Defensive: If any assumption objects are NULL, tell the user to check assumptions.
      if (
        is.null(shap1_val()) || is.null(shap2_val()) || is.null(mvn_p_val()) ||
        is.null(mvn_ok_val()) || is.null(car_outliers_val()) || is.null(perf_het_val())
      ) {
        return(div(style = "background-color:#f5f5f5; color:#333; padding:18px; border-radius:8px; margin-top:10px;",
                   icon("exclamation-circle", lib = "font-awesome"),
                   strong("Assumption checks require exactly two features. Please select two features and check assumptions.")
        ))
      }
      tagList(
        #h4("Assumption Checks"),

        # 1. Linearity
        div(
          br(),
          h5(HTML("1. Linearity (scatterplot) <i
    class='fa-solid fa-circle-info'
    data-bs-toggle='tooltip'
    data-bs-placement='right'
    title='This scatterplot shows the relationship between the two selected variables. The red line is a linear regression fit. If points follow the line, the relationship is linear.'
    style='color:#2c3e50; cursor:pointer; font-size:16px; margin-left:10px;'></i>"))
        ),
        fluidRow(
          column(width = 8,  # or 6 for even narrower
                 offset = 2,  # centers it horizontally
                 plotOutput("cor_linearity_plot")
          )
        ),

        div(
          style = "text-align:center; margin-top: 12px; margin-bottom: 18px;",
          downloadButton("cor_download_plot", "Download Scatter Plot", 
                         class = "no-print cor-hide-in-screenshot")
        ),
        br(),


        # 2. Normality
        h5("2. Shapiro-Wilk Normality"),
        verbatimTextOutput("cor_shapiro_text"),
        div(
          style = paste0("background-color:",
                         if (!is.null(shap1_val()) && !is.null(shap2_val()) && shap1_val()$p.value > 0.05 &&
                             shap2_val()$p.value > 0.05) "green" else "#B20D00",
                         "; color: white; padding: 5px; border-radius: 5px;"),
          if (!is.null(shap1_val()) && !is.null(shap2_val()) && shap1_val()$p.value > 0.05 &&
              shap2_val()$p.value > 0.05) {
            "Both variables appear normally distributed."
          } else {
            "One or both variables are NOT normally distributed."
          }
        ),
        br(),


        # 3. Bivariate normality
        h5("3. Bivariate Normality (Henze-Wagner test)"),
        verbatimTextOutput("cor_mvn_text"),
        div(
          style = paste0(
            "background-color:", if (!is.na(mvn_p) && mvn_ok) "green" else "#B20D00",
            "; color: white; padding: 5px; border-radius: 5px;"
          ),
          if (!is.na(mvn_p_val())) {
            if (mvn_ok_val()) {
              paste0("Bivariate normality assumption met")
            } else {
              paste0("Bivariate normality NOT met")
            }
          } else if (is.character(mvn_res)) {
            mvn_res
          } else if (is.data.frame(mvn_res)) {
            "Henze-Zirkler test result returned as data.frame but p-value could not be determined."
          } else {
            "Test failed or not applicable."
          }
        ),
        br(),


        # 4. Outliers
        h5("4. Outlier Test"),
        verbatimTextOutput("cor_outlier_text"),
        div(
          style = paste0(
            "background-color:",
            {
              if (is.null(car_outliers_val())) {
                "green"
              } else if (inherits(car_outliers_val(), "outlierTest")) {
                "green"
              } else if (is.data.frame(car_outliers_val()) &&
                         "Bonferroni p" %in% colnames(car_outliers_val()) &&
                         isTRUE(any(!is.na(car_outliers_val()[,"Bonferroni p"]))) &&
                         isTRUE(any(car_outliers_val()[,"Bonferroni p"] <= 0.05))) {
                "#B20D00"
              } else {
                "green"
              }
            },
            "; color: white; padding: 5px; border-radius: 5px;"
          ),
          {
            if (is.null(car_outliers_val())) {
              "No significant outliers detected."
            } else if (inherits(car_outliers_val(), "outlierTest")) {
              "No significant outliers detected."
            } else if (is.data.frame(car_outliers_val()) &&
                       "Bonferroni p" %in% colnames(car_outliers_val()) &&
                       isTRUE(any(!is.na(car_outliers_val()[,"Bonferroni p"]))) &&
                       isTRUE(any(car_outliers_val()[,"Bonferroni p"] <= 0.05))) {
              "Potential outliers detected."
            } else {
              "No significant outliers detected."
            }
          }
        ),
        br(),



        # 5. Homoscedasticity
        h5("5. Homoscedasticity"),
        verbatimTextOutput("cor_het_text"),
        uiOutput("cor_het_box"),
        br(),
        h4("Assumption Check Summary"),
        uiOutput("cor_assumption_summary")
        )
      })

    output$cor_result_content <- renderUI({
      tagList(
        #h4("Correlation Results"),
        verbatimTextOutput("cor_result_table"),
        uiOutput("cor_sig_square")
      )
    })


    output$cor_het_box <- renderUI({
      ph <- perf_het_val()
      pval <- NULL
      # Robustly extract p.value
      if (!is.null(ph)) {
        # If ph is a list and contains p.value
        if (is.list(ph) && "p.value" %in% names(ph)) {
          pval <- ph[["p.value"]]
        }
        # If ph is an atomic vector with names
        else if (!is.null(names(ph)) && "p.value" %in% names(ph)) {
          pval <- ph[["p.value"]]
        }
        # If ph itself is a single numeric p-value
        else if (is.numeric(ph) && length(ph) == 1) {
          pval <- ph
        }
      }
      div(
        style = paste0(
          "background-color:",
          if (!is.null(pval) && isTRUE(all(pval > 0.05))) "green" else "#B20D00",
          "; color: white; padding: 5px; border-radius: 5px;"
        ),
        if (!is.null(pval)) {
          if (isTRUE(all(pval > 0.05))) {
            paste0("Variance appears homoscedastic.")
          } else {
            paste0("Variance is NOT homoscedastic.")
          }
        } else {
          "Test failed or not applicable."
        }
      )
    })




    # Outputs for assumption test details
    output$cor_linearity_plot <- renderPlot({ scatter_plot_val() })
    output$cor_shapiro_text <- renderPrint({
      tbl <- data.frame(
        Variable = c(input$cor_features[1], input$cor_features[2]),
        `Shapiro-Wilk p` = c(
          if (!is.null(shap1_val())) signif(shap1_val()$p.value, 3) else NA,
          if (!is.null(shap2_val())) signif(shap2_val()$p.value, 3) else NA
        )
      )
      print(knitr::kable(tbl, align = "c", format = "simple"))
    })


    # Bivariate
    output$cor_mvn_text <- renderPrint({
      val <- mvn_p_val()
      if (!is.null(val) && !is.na(val)) {
        cat(sprintf("HZ test p = %.4g", val))
      } else {
        cat("Test not run.")
      }
    })
    


    output$cor_outlier_text <- renderPrint({
      if (!is.null(car_outliers)) print(car_outliers) else "No outliers detected or not applicable."
    })
    output$cor_het_text <- renderPrint({
      if (!is.null(perf_het)) print(perf_het) else "Test failed."
    })

  })

  cor_assumption_summary <- reactive({
    pass_linearity <- !is.null(scatter_plot_val())
    pass_normality <- safe_shapiro_pval(shap1_val()) && safe_shapiro_pval(shap2_val()) &&
      shap1_val()$p.value > 0.05 && shap2_val()$p.value > 0.05
    pass_bivnorm  <- !is.na(mvn_p_val()) && isTRUE(mvn_ok_val())
    pass_outliers <- is.null(car_outliers_val()) ||
      (inherits(car_outliers_val(), "outlierTest")) ||
      (is.data.frame(car_outliers_val()) &&
         "Bonferroni p" %in% colnames(car_outliers_val()) &&
         (isTRUE(all(is.na(car_outliers_val()[,"Bonferroni p"]))) ||
            isTRUE(all(car_outliers_val()[,"Bonferroni p"] > 0.05))))

    pass_het <- {
      ph <- perf_het_val()
      pval <- NULL
      if (!is.null(ph)) {
        if (is.list(ph) && "p.value" %in% names(ph)) {
          pval <- ph[["p.value"]]
        } else if (!is.null(names(ph)) && "p.value" %in% names(ph)) {
          pval <- ph[["p.value"]]
        } else if (is.numeric(ph) && length(ph) == 1) {
          pval <- ph
        }
      }
      !is.null(pval) && isTRUE(all(pval > 0.05))
    }

    assumptions <- c(Linearity = pass_linearity,
                     Normality = pass_normality,
                     BivariateNormality = pass_bivnorm,
                     Outliers = pass_outliers,
                     Homoscedasticity = pass_het)
    n_failed <- sum(!assumptions)

    if (n_failed == 0) {
      div(
        style = "background-color: green; color: white; padding: 10px; border-radius: 5px; margin-top: 18px;",
        strong("✓ All Assumptions Passed"),
        p("Pearson correlation is appropriate. Proceed with the analysis.")
      )
    } else {
      div(
        style = "background-color: #B20D00; color: white; padding: 10px; border-radius: 5px; margin-top: 10px;",
        strong("✗ Assumptions Not Met"),
        p("Consider a non-parametric method such as ",
          strong("Spearman correlation, Kendall correlation, or Biweight midcorrelation (bicor).")
        )
      )
    }
  })


  output$cor_assumption_summary <- renderUI({
    cor_assumption_summary()
  })


  make_scatter_plot <- function(v1, v2, var1_name, var2_name) {
    ggplot(data.frame(x = v1, y = v2), aes(x, y)) +
      geom_point(size = 2, alpha = 0.7) +
      geom_smooth(method = "lm", se = FALSE, color = "red") +
      theme_bw() +
      labs(title = "Scatterplot with Regression Line",
           x = var1_name, y = var2_name)
  }

 # Download the Scatter plot
  output$cor_download_plot <- downloadHandler(
    filename = function() { paste0("scatter_plot_", Sys.Date(), ".png") },
    content = function(file) {
      df <- cor_clr_data()
      v1 <- df[[input$cor_features[1]]]
      v2 <- df[[input$cor_features[2]]]
      p <- make_scatter_plot(v1, v2, input$cor_features[1], input$cor_features[2])
      ggsave(file, plot = p, width = 7, height = 5, dpi = 600)
    }
  )

  
  # screenshot of correlation
  
  cor_assumptions_checked <- reactiveVal(FALSE)
  observeEvent(list(input$cor_features, input$cor_method, input$cor_file), {
    cor_assumptions_checked(FALSE)
  })
  
  observeEvent(input$cor_check_assumptions, {
    cor_assumptions_checked(TRUE)
  })
  
  
  observeEvent(input$cor_start_screenshot, {
    shinyscreenshot::screenshot(selector = "#cor_report_content", scale = 8)
  })
  
  
  div(id = "cor_report_content", uiOutput("cor_assumption_content"))
  
  output$cor_show_screenshot_btn <- renderUI({
    if (!is.null(cor_selected_data()) && 
        !is.null(input$cor_features) &&
        length(input$cor_features) == 2 && 
        input$cor_method == "pearson" &&
        cor_assumptions_checked()) {
      div(
        id = "cor_screenshot_div",
        actionButton(
          "cor_screenshot_btn",
          "Download Full Report",
          class = "btn-plot",
          onclick = "corScreenshotWithoutScatterBtn()"
        )
      )
    }
  })
  
  

  # Show correlation table if ≤10 features
  output$cor_table_ui <- renderUI({
    req(input$cor_run)
    valid_methods <- c("pearson", "spearman", "kendall", "biweight")
    if (!(input$cor_method %in% valid_methods)) return(NULL)

    n_feat <- length(input$cor_features)

    # ----- HANDLE PEARSON WITH EXACTLY 2 FEATURES -----
    if (input$cor_method == "pearson" && n_feat == 2) {
      assumptions_checked <- !is.null(shap1_val()) && !is.null(shap2_val()) &&
        !is.null(mvn_p_val()) && !is.null(mvn_ok_val()) &&
        !is.null(car_outliers_val()) && !is.null(perf_het_val())

      if (!assumptions_checked) {
        return(
          div(style = "background-color: #e0e0e0; color: #222; padding: 14px; border-radius: 5px; font-size: 1.1em; margin-top: 10px;",
              strong("Please check the assumptions before running Pearson correlation."))
        )
      }

      # Assumptions checked but not all passed → show gray warning
      pass_linearity <- !is.null(scatter_plot_val())
      pass_normality <- safe_shapiro_pval(shap1_val()) && safe_shapiro_pval(shap2_val()) &&
        shap1_val()$p.value > 0.05 && shap2_val()$p.value > 0.05
      pass_bivnorm  <- !is.na(mvn_p_val()) && isTRUE(mvn_ok_val())
      pass_outliers <- is.null(car_outliers_val()) ||
        (inherits(car_outliers_val(), "outlierTest")) ||
        (is.data.frame(car_outliers_val()) &&
           "Bonferroni p" %in% colnames(car_outliers_val()) &&
           (isTRUE(all(is.na(car_outliers_val()[,"Bonferroni p"]))) ||
              isTRUE(all(car_outliers_val()[,"Bonferroni p"] > 0.05))))
      pass_het <- {
        ph <- perf_het_val()
        pval <- NULL
        if (!is.null(ph)) {
          if (is.list(ph) && "p.value" %in% names(ph)) pval <- ph[["p.value"]]
          else if (!is.null(names(ph)) && "p.value" %in% names(ph)) pval <- ph[["p.value"]]
          else if (is.numeric(ph) && length(ph) == 1) pval <- ph
        }
        !is.null(pval) && isTRUE(all(pval > 0.05))
      }
      pass_all <- all(c(pass_linearity, pass_normality, pass_bivnorm, pass_outliers, pass_het))

      if (!pass_all) {
        return(
          div(style = "background-color: #e0e0e0; color: #222; padding: 14px; border-radius: 5px; font-size: 1.1em; margin-top: 10px;",
              strong("This test is not suitable for your data. Assumptions for this test are not met."))
        )
      }
    }

    # ----- SHOW WARNING FOR PEARSON WITH >2 FEATURES -----
    warn_msg <- NULL
    if (input$cor_method == "pearson" && n_feat > 2) {
      warn_msg <- div(
        style = "background-color:#fff3cd; color:#856404; padding:14px; border:1px solid #ffeeba; border-radius:5px; margin-bottom:12px;",
        icon("exclamation-triangle", lib = "font-awesome"),
        strong(" Pearson warning: "),
        "Assumptions were only checked for 2-variable case. No guarantee of validity for all pairs."
      )
    }

    table_output <- if (n_feat <= 10) {
      DT::dataTableOutput("cor_table")
    } else {
      div(
        style = "background-color:#fff3cd; color:#856404; padding:14px; border:1px solid #ffeeba; border-radius:5px; margin-top:8px; margin-bottom:12px;",
        icon("exclamation-triangle", lib = "font-awesome"),
        strong("You selected more than 10 features. View full results by downloading tables below.")
      )
      
    }

    tagList(warn_msg, table_output)
  })




  # Table Output Logic
  output$cor_table <- DT::renderDataTable({
    req(input$cor_run)

    valid_methods <- c("pearson", "spearman", "kendall", "biweight")
    if (!(input$cor_method %in% valid_methods)) return(NULL)

    df <- cor_clr_data()
    if (is.null(df)) return(NULL)

    # Block only if Pearson + exactly 2 vars + assumptions not tested
    if (input$cor_method == "pearson" && length(input$cor_features) == 2) {
      assumptions_tested <- !is.null(shap1_val()) &&
        !is.null(shap2_val()) &&
        !is.null(mvn_p_val()) && !is.null(mvn_ok_val()) &&
        !is.null(car_outliers_val()) && !is.null(perf_het_val())

      if (!assumptions_tested) {
        showModal(modalDialog(
          div(
            style = "background-color: #e0e0e0; color: #222; padding: 14px; border-radius: 5px; font-size: 1.1em; margin-top: 10px;",
            strong("Please check the assumptions before running Pearson correlation.")
          ),
          easyClose = TRUE
        ))
        return(NULL)
      }
    }

    # Run correlation regardless of n_features if not blocked
    cor_df <- correlation::correlation(df,
                                       method = input$cor_method,
                                       p_adjust = input$cor_p_adjust)
    DT::datatable(as.data.frame(cor_df), options = list(scrollX = TRUE))
  })







      # safe_pass_normality <- (
      #   !is.null(shap1_val()) && !is.null(shap2_val()) &&
      #     !is.null(shap1_val()$p.value) && !is.null(shap2_val()$p.value) &&
      #     shap1_val()$p.value > 0.05 && shap2_val()$p.value > 0.05
      # )
      # Now, check if assumptions are actually met
  #     pass_linearity <- !is.null(scatter_plot_val())
  #     pass_normality <- safe_shapiro_pval(shap1_val()) && safe_shapiro_pval(shap2_val()) &&
  #       shap1_val()$p.value > 0.05 && shap2_val()$p.value > 0.05
  #     pass_bivnorm  <- !is.na(mvn_p_val()) && isTRUE(mvn_ok_val())
  #     pass_outliers <- is.null(car_outliers_val()) ||
  #       (inherits(car_outliers_val(), "outlierTest")) ||
  #       (is.data.frame(car_outliers_val()) &&
  #          "Bonferroni p" %in% colnames(car_outliers_val()) &&
  #          (isTRUE(all(is.na(car_outliers_val()[,"Bonferroni p"]))) ||
  #             isTRUE(all(car_outliers_val()[,"Bonferroni p"] > 0.05))))
  #     pass_het <- {
  #       ph <- perf_het_val()
  #       pval <- NULL
  #       if (!is.null(ph)) {
  #         if (is.list(ph) && "p.value" %in% names(ph)) pval <- ph[["p.value"]]
  #         else if (!is.null(names(ph)) && "p.value" %in% names(ph)) pval <- ph[["p.value"]]
  #         else if (is.numeric(ph) && length(ph) == 1) pval <- ph
  #       }
  #       !is.null(pval) && isTRUE(all(pval > 0.05))
  #     }
  #     pass_all <- all(c(pass_linearity, pass_normality, pass_bivnorm, pass_outliers, pass_het))
  #     if (!pass_all) {
  #       return(
  #         div(style = "background-color: #e0e0e0; color: #222; padding: 14px; border-radius: 5px; font-size: 1.1em; margin-top: 10px;",
  #             strong("This test is not suitable for your data. Assumptions for Pearson are not met.")
  #         )
  #       )
  #     }
  #   }
  #   # If not Pearson, or all assumptions passed:
  #   df <- cor_clr_data()
  #   cor_df <- correlation::correlation(df, method = input$cor_method, p_adjust = input$cor_p_adjust)
  #   #as.data.frame(cor_df)
  # #})



  # Show correlation matrix download if >10 feature
  output$cor_matrix_ui <- renderUI({
    req(input$cor_run)
    valid_methods <- c("pearson", "spearman", "kendall", "biweight")
    if (!(input$cor_method %in% valid_methods)) {
      return(
        div(
          style = "background-color:#f8d7da; color:#721c24; border:1px solid #f5c6cb; padding:16px; border-radius:6px; margin-top:16px; font-size:1.08em;",
          icon("exclamation-circle", lib = "font-awesome"),
          strong(" Please select a valid correlation method before running the analysis.")
        )
      )
    }

    n_feat <- length(input$cor_features)
    if (input$cor_method == "pearson" && n_feat == 2) {
      if (is.null(shap1_val()) || is.null(shap2_val()) || is.null(mvn_p_val()) || is.null(mvn_ok_val()) ||
          is.null(car_outliers_val()) || is.null(perf_het_val())) {
        return(
          div(style = "background-color: #e0e0e0; color: #222; padding: 14px; border-radius: 5px; font-size: 1.1em; margin-top: 10px;",
              strong("Please check the assumptions before running Pearson correlation.")
          )
        )
      }

      # Check assumption PASS status
      pass_linearity <- !is.null(scatter_plot_val())
      pass_normality <- safe_shapiro_pval(shap1_val()) && safe_shapiro_pval(shap2_val()) &&
        shap1_val()$p.value > 0.05 && shap2_val()$p.value > 0.05
      pass_bivnorm <- !is.na(mvn_p_val()) && isTRUE(mvn_ok_val())
      pass_outliers <- is.null(car_outliers_val()) ||
        (inherits(car_outliers_val(), "outlierTest")) ||
        (is.data.frame(car_outliers_val()) &&
           "Bonferroni p" %in% colnames(car_outliers_val()) &&
           (isTRUE(all(is.na(car_outliers_val()[,"Bonferroni p"]))) ||
              isTRUE(all(car_outliers_val()[,"Bonferroni p"] > 0.05))))
      pass_het <- {
        ph <- perf_het_val()
        pval <- NULL
        if (!is.null(ph)) {
          if (is.list(ph) && "p.value" %in% names(ph)) pval <- ph[["p.value"]]
          else if (!is.null(names(ph)) && "p.value" %in% names(ph)) pval <- ph[["p.value"]]
          else if (is.numeric(ph) && length(ph) == 1) pval <- ph
        }
        !is.null(pval) && isTRUE(all(pval > 0.05))
      }
      pass_all <- all(c(pass_linearity, pass_normality, pass_bivnorm, pass_outliers, pass_het))
      if (!pass_all) {
        return(
          div(style = "background-color: #e0e0e0; color: #222; padding: 14px; border-radius: 5px; font-size: 1.1em; margin-top: 10px;",
              strong("This test is not suitable for your data. Assumptions for Pearson are not met.")
          )
        )
      }
    }

    if (n_feat <= 10) {
      DT::dataTableOutput("cor_matrix")
    } else {
      div(style="color:#a00; margin-top:8px;",
          "Matrix format available for ≤10 features only. Download the matrix below for full results.")
    }
  })

  # Show the correlation matrix
  output$cor_matrix <- DT::renderDataTable({
    req(input$cor_run)
    valid_methods <- c("pearson", "spearman", "kendall", "biweight")
    if (!(input$cor_method %in% valid_methods)) {
      return(
        div(
          style = "background-color:#f8d7da; color:#721c24; border:1px solid #f5c6cb; padding:16px; border-radius:6px; margin-top:16px; font-size:1.08em;",
          icon("exclamation-circle", lib = "font-awesome"),
          strong(" Please select a valid correlation method before running the analysis.")
        )
      )
    }

    df <- cor_clr_data()
    cor_mat <- correlation::correlation(df, method = input$cor_method, p_adjust = input$cor_p_adjust) %>%
      summary(redundant = TRUE)
    as.data.frame(cor_mat)
  })

output$cor_matrix_download <- downloadHandler(
  filename = function() {
    paste0("correlation_matrix_", Sys.Date(), ".csv")
  },
  content = function(file) {
    df <- cor_clr_data()
    if (is.null(df)) return(NULL)

    method <- input$cor_method
    n_feat <- length(input$cor_features)

    # Block Pearson with 2 features and failed assumptions
    if (method == "pearson" && n_feat == 2) {
      assumptions_tested <- !is.null(shap1_val()) &&
        !is.null(shap2_val()) &&
        !is.null(mvn_p_val()) && !is.null(mvn_ok_val()) &&
        !is.null(car_outliers_val()) && !is.null(perf_het_val())
      if (!assumptions_tested) return(NULL)

      pass_linearity <- !is.null(scatter_plot_val())
      pass_normality <- safe_shapiro_pval(shap1_val()) && safe_shapiro_pval(shap2_val()) &&
        shap1_val()$p.value > 0.05 && shap2_val()$p.value > 0.05
      pass_bivnorm  <- !is.na(mvn_p_val()) && isTRUE(mvn_ok_val())
      pass_outliers <- is.null(car_outliers_val()) ||
        (inherits(car_outliers_val(), "outlierTest")) ||
        (is.data.frame(car_outliers_val()) &&
           "Bonferroni p" %in% colnames(car_outliers_val()) &&
           (all(is.na(car_outliers_val()[,"Bonferroni p"])) ||
              all(car_outliers_val()[,"Bonferroni p"] > 0.05)))
      pass_het <- {
        ph <- perf_het_val()
        pval <- NULL
        if (!is.null(ph)) {
          if (is.list(ph) && "p.value" %in% names(ph)) pval <- ph[["p.value"]]
          else if (!is.null(names(ph)) && "p.value" %in% names(ph)) pval <- ph[["p.value"]]
          else if (is.numeric(ph) && length(ph) == 1) pval <- ph
        }
        !is.null(pval) && all(pval > 0.05)
      }

      if (!all(c(pass_linearity, pass_normality, pass_bivnorm, pass_outliers, pass_het))) return(NULL)
    }

    # If passed, write the matrix
    cor_mat <- correlation::correlation(df, method = method, p_adjust = input$cor_p_adjust) %>%
      summary(redundant = TRUE)
    write.csv(as.data.frame(cor_mat), file, row.names = FALSE)
  }
)

output$cor_matrix_download_ui <- renderUI({
  req(input$cor_run)
  valid_methods <- c("pearson", "spearman", "kendall", "biweight")
  if (!(input$cor_method %in% valid_methods)) return(NULL)
  n_feat <- length(input$cor_features)
  if (n_feat < 2) return(NULL)

  # Pearson + 2 vars: block if assumptions not met
  if (input$cor_method == "pearson" && n_feat == 2) {
    if (is.null(shap1_val()) || is.null(shap2_val()) ||
        is.null(mvn_p_val()) || is.null(mvn_ok_val()) ||
        is.null(car_outliers_val()) || is.null(perf_het_val())) return(NULL)

    pass_linearity <- !is.null(scatter_plot_val())
    pass_normality <- safe_shapiro_pval(shap1_val()) && safe_shapiro_pval(shap2_val()) &&
      shap1_val()$p.value > 0.05 && shap2_val()$p.value > 0.05
    pass_bivnorm  <- !is.na(mvn_p_val()) && isTRUE(mvn_ok_val())
    pass_outliers <- is.null(car_outliers_val()) ||
      (inherits(car_outliers_val(), "outlierTest")) ||
      (is.data.frame(car_outliers_val()) &&
         "Bonferroni p" %in% colnames(car_outliers_val()) &&
         (all(is.na(car_outliers_val()[,"Bonferroni p"])) ||
            all(car_outliers_val()[,"Bonferroni p"] > 0.05)))
    pass_het <- {
      ph <- perf_het_val()
      pval <- NULL
      if (!is.null(ph)) {
        if (is.list(ph) && "p.value" %in% names(ph)) pval <- ph[["p.value"]]
        else if (!is.null(names(ph)) && "p.value" %in% names(ph)) pval <- ph[["p.value"]]
        else if (is.numeric(ph) && length(ph) == 1) pval <- ph
      }
      !is.null(pval) && all(pval > 0.05)
    }

    if (!all(c(pass_linearity, pass_normality, pass_bivnorm, pass_outliers, pass_het))) return(NULL)
  }

  tagList(
    downloadButton("cor_matrix_download", "Download Matrix"),
    div(style = "margin-bottom: 5px;")
  )
})




  # Heatmap
  output$cor_heatmap_ui <- renderUI({
    req(input$cor_run)
    valid_methods <- c("pearson", "spearman", "kendall", "biweight")
    if (!(input$cor_method %in% valid_methods)) return(NULL)

    n_feat <- length(input$cor_features)

    if (input$cor_method == "pearson" && n_feat == 2) return(NULL)

    if (input$cor_method == "pearson" && n_feat > 2) {
      return(
        if (n_feat < 5 || n_feat > 20) {
          return(div(
            style = "background-color:#fff3cd; color:#856404; padding:14px; border:1px solid #ffeeba; border-radius:5px; margin-top:8px; margin-bottom:12px;",
            icon("exclamation-triangle", lib = "font-awesome"),
            strong("Heatmap only available for 5–20 features.")
          ))
        } else {
          plotOutput("cor_heatmap", height = "600px", width = "100%")
        }
      )
    }

    # For other methods (spearman, etc.)
    if (n_feat < 5 || n_feat > 20) {
      return(div(
        style = "background-color:#fff3cd; color:#856404; padding:14px; border:1px solid #ffeeba; border-radius:5px; margin-top:8px; margin-bottom:12px;",
        icon("exclamation-triangle", lib = "font-awesome"),
        strong("Heatmap only available for 5–20 features.")
      ))
    }

    plotOutput("cor_heatmap", height = "600px", width = "100%")
  })





  output$cor_heatmap <- renderPlot({
    req(input$cor_run)
    valid_methods <- c("pearson", "spearman", "kendall", "biweight")
    if (!(input$cor_method %in% valid_methods)) {
      return(
        div(
          style = "background-color:#f8d7da; color:#721c24; border:1px solid #f5c6cb; padding:16px; border-radius:6px; margin-top:16px; font-size:1.08em;",
          icon("exclamation-circle", lib = "font-awesome"),
          strong(" Please select a valid correlation method before running the analysis.")
        )
      )
    }

    df <- cor_clr_data()
    n_feat <- length(input$cor_features)
    if (n_feat < 5 || n_feat > 20) return(NULL)
    cormat <- correlation::correlation(df, method = input$cor_method, p_adjust = input$cor_p_adjust) %>%
      summary(redundant = TRUE)
    cormat_mat <- as.matrix(cormat[,-1])
    rownames(cormat_mat) <- cormat[,1]
    
    
    # --- Dynamic label size ---
    tl_size <- ifelse(n_feat > 15, 1.4,
                      ifelse(n_feat > 10, 1.4, 1.4))
    cl_size <- ifelse(n_feat > 15, 1.3,
                      ifelse(n_feat > 10, 1.4, 1.4))
    
    corrplot::corrplot(
      cormat_mat, type = "lower", na.label = NA, outline = TRUE, order = "hclust",
      tl.cex = tl_size, cl.cex = cl_size, tl.srt = 45, tl.col = "black", cl.ratio = 0.2,
      col = rev(corrplot::COL2('RdBu', 200))
    )
  })



 # Download
  output$cor_download_table <- downloadHandler(
    filename = function() paste0("correlation_table_", Sys.Date(), ".csv"),
    content = function(file) {
      df <- cor_clr_data()
      cor_df <- correlation::correlation(df, method = input$cor_method, p_adjust = input$cor_p_adjust)
      write.csv(as.data.frame(cor_df), file, row.names = FALSE)
    }
  )


  output$cor_download_heatmap <- downloadHandler(
    filename = function() paste0("correlation_heatmap_", Sys.Date(), ".pdf"),
    content = function(file) {
      df <- cor_clr_data()
      n_feat <- length(input$cor_features)
      if (n_feat >= 5 && n_feat <= 20) {
        cormat <- correlation::correlation(df, method = input$cor_method, p_adjust = input$cor_p_adjust) %>%
          summary(redundant = TRUE)
        cormat_mat <- as.matrix(cormat[,-1])
        rownames(cormat_mat) <- cormat[,1]
        
        # --- Dynamic label size adjustment ---
        tl_size <- ifelse(n_feat > 15, 1, # font size
                          ifelse(n_feat > 10, 1.1, 1))
        cl_size <- ifelse(n_feat > 15, 1, # color legend
                          ifelse(n_feat > 10, 1, 1))
        
        #png(file, width = 500 + 60 * n_feat, height = 400 + 60 * n_feat, res = 300)
        pdf(file, width = 8, height = 6)
        oldpar <- par(no.readonly = TRUE)
        on.exit({
          par(oldpar)
          dev.off()
        })
        par(mar = c(2, 2, 2, 2)) # adjust if needed
        corrplot::corrplot(
          cormat_mat, type = "lower", na.label = NA, outline = TRUE, order = "hclust",
          tl.cex = tl_size, cl.cex = cl_size, tl.srt = 45, tl.col = "black", cl.ratio = 0.2,
          col = rev(corrplot::COL2('RdBu', 200))
        )
      }
    }
  )
  

    # Define reactiveVals first
    perf_het_val <- reactiveVal(NULL)
    scatter_plot_val <- reactiveVal(NULL)
    shap1_val <- reactiveVal(NULL)
    shap2_val <- reactiveVal(NULL)
    mvn_p_val <- reactiveVal(NULL)
    mvn_ok_val <- reactiveVal(NULL)
    car_outliers_val <- reactiveVal(NULL)

    # Reset when method/features change
    observeEvent(input$cor_method, {
      shap1_val(NULL)
      shap2_val(NULL)
      mvn_p_val(NULL)
      mvn_ok_val(NULL)
      car_outliers_val(NULL)
      perf_het_val(NULL)
    })
    observeEvent(input$cor_features, {
      shap1_val(NULL)
      shap2_val(NULL)
      mvn_p_val(NULL)
      mvn_ok_val(NULL)
      car_outliers_val(NULL)
      perf_het_val(NULL)
    })

    observeEvent(input$cor_file, {
      updateSelectInput(session, "cor_method", selected = "")
      updateSelectInput(session, "cor_p_adjust", selected = "BH")
      updateCheckboxInput(session, "cor_do_clr", value = FALSE)
      updateSliderInput(session, "cor_prev_filter", value = 0)
      num_cols <- cor_numeric_features()
      updateSelectInput(session, "cor_features", selected = num_cols[seq_len(min(2, length(num_cols)))])


      # Clear assumption values
      shap1_val(NULL)
      shap2_val(NULL)
      mvn_p_val(NULL)
      mvn_ok_val(NULL)
      car_outliers_val(NULL)
      perf_het_val(NULL)
      scatter_plot_val(NULL)
    })

    output$cor_download_heatmap_ui <- renderUI({
      req(input$cor_run)
      valid_methods <- c("pearson", "spearman", "kendall", "biweight")
      if (!(input$cor_method %in% valid_methods)) return(NULL)

      n_feat <- length(input$cor_features)

      if (input$cor_method == "pearson" && n_feat == 2) return(NULL)
      if (n_feat < 5 || n_feat > 20) return(NULL)

      tagList(
        downloadButton("cor_download_heatmap", "Download Heatmap"),
        tags$div(style = "margin-top: 5px;")
      )
    })





    output$cor_download_table_ui <- renderUI({
      req(input$cor_run)
      method <- input$cor_method
      n_feat <- length(input$cor_features)

      valid_methods <- c("pearson", "spearman", "kendall", "biweight")
      if (!(method %in% valid_methods) || n_feat < 2) return(NULL)

      # Special case: Pearson with exactly 2 features
      if (method == "pearson" && n_feat == 2) {
        # Check if assumptions were tested
        if (is.null(shap1_val()) || is.null(shap2_val()) ||
            is.null(mvn_p_val()) || is.null(mvn_ok_val()) ||
            is.null(car_outliers_val()) || is.null(perf_het_val())) return(NULL)

        # Check if assumptions passed
        pass_linearity <- !is.null(scatter_plot_val())
        pass_normality <- safe_shapiro_pval(shap1_val()) && safe_shapiro_pval(shap2_val()) &&
          shap1_val()$p.value > 0.05 && shap2_val()$p.value > 0.05
        pass_bivnorm  <- !is.na(mvn_p_val()) && isTRUE(mvn_ok_val())
        pass_outliers <- is.null(car_outliers_val()) ||
          (inherits(car_outliers_val(), "outlierTest")) ||
          (is.data.frame(car_outliers_val()) &&
             "Bonferroni p" %in% colnames(car_outliers_val()) &&
             (all(is.na(car_outliers_val()[,"Bonferroni p"])) ||
                all(car_outliers_val()[,"Bonferroni p"] > 0.05)))
        pass_het <- {
          ph <- perf_het_val()
          pval <- NULL
          if (!is.null(ph)) {
            if (is.list(ph) && "p.value" %in% names(ph)) pval <- ph[["p.value"]]
            else if (!is.null(names(ph)) && "p.value" %in% names(ph)) pval <- ph[["p.value"]]
            else if (is.numeric(ph) && length(ph) == 1) pval <- ph
          }
          !is.null(pval) && all(pval > 0.05)
        }

        if (!all(c(pass_linearity, pass_normality, pass_bivnorm, pass_outliers, pass_het))) return(NULL)
      }

      # All other cases: Spearman, Kendall, Biweight, or Pearson with >2 features
      downloadButton("cor_download_table", "Download Table")
    })

############################################################################################################
############################################################################################################
############################################################################################################
############################################################################################################
############################################################################################################
############################################################################################################
############################################################################################################
############################################################################################################

    # Regression analysis

    ## ------- Linear model -------- #
    lm_assump_plot_val <- reactiveVal(NULL)

    # ---- LM Data Loader ----
    lm_data <- reactive({
      req(input$lm_file)
      readr::read_csv(input$lm_file$datapath, show_col_types = F)
    })

    # ---- LM: UI for Dependent Variable ----
    output$lm_dep_ui <- renderUI({
      df <- lm_data()
      num_vars <- names(df)[sapply(df, function(col) {
        is.numeric(col) &&
          length(unique(col)) > 10 &&
          any(col %% 1 != 0, na.rm = TRUE)  # exclude integer-only
      })]
      tagList(
        selectInput("lm_dep", "Select dependent variable (continuous):",
                    choices = c("Select variable" = "", num_vars),
                    selected = ""),
        tags$div(
          style = "color: #b2182b; font-size: 13px; font-weight: bold; margin-top: -10px; margin-bottom: 10px;",
          icon("info-circle", lib = "font-awesome"),
          "Only continuous variables are shown. Count or discrete variables are excluded, as they violate model assumptions. For count outcomes, please use the negative binomial option."
        )
      )
    })

    # ---- LM: UI for Independent Variables ----
    output$lm_indep_ui <- renderUI({
      df <- lm_data()
      all_vars <- names(df)
      # Remove dependent from choices if selected
      choices <- setdiff(all_vars, input$lm_dep)
      selectizeInput(
        "lm_indep",
        "Select independent variables:", choices = choices, multiple = TRUE, selected = NULL,
        options = list(placeholder = "Select variable"))
    })

    # ---- Reset Independent Variable Choices When Dependent Changes ----
    observeEvent(input$lm_dep, {
      df <- lm_data()
      all_vars <- names(df)
      choices <- setdiff(all_vars, input$lm_dep)
      updateSelectizeInput(session, "lm_indep", choices = choices)
    })


    # ---- LM: Reactive for Final Model Data (checks and subset) ----
    lm_model_data <- reactive({
      req(lm_data(), input$lm_dep, input$lm_indep)
      df <- lm_data()
      # Remove rows with NA in model variables
      model_vars <- c(input$lm_dep, input$lm_indep)
      df <- df %>% dplyr::select(all_of(model_vars)) %>% tidyr::drop_na()
      # Defensive: Check again
      if (input$lm_dep %in% input$lm_indep) {
        showNotification(strong("Dependent variable cannot be included as independent."), type = "error")
        return(NULL)
      }
      if (length(input$lm_indep) < 1) {
        showNotification(strong("Please select at least one independent variable."), type = "error")
        return(NULL)
      }
      df
    })


    # ---- LM: UI for Interactions ----
    output$lm_interact_ui <- renderUI({
      req(input$lm_indep)
      if (length(input$lm_indep) < 2) return(NULL)
      # Allow user to select 2-way interactions
      combos <- combn(input$lm_indep, 2, simplify = FALSE)
      interact_labels <- sapply(combos, function(x) paste(x, collapse = " : "))
      selectizeInput("lm_interact", "Add interaction term(s):",
                     choices = setNames(sapply(combos, paste, collapse = ":"), interact_labels),
                     multiple = TRUE, selected = NULL,
                     options = list(placeholder = "Select interaction(s)"))
    })

    # Add to UI: call uiOutput("lm_interact_ui") just after uiOutput("lm_indep_ui")

    # ---- LM: Run Model and Show Result Table with Interactions ----
    observeEvent(input$lm_run, {
      if (is.null(input$lm_file)) {
        showNotification(strong("Please upload a data file."), type = "error")
        return()
      }
      if (is.null(input$lm_dep) || input$lm_dep == "") {
        showNotification(strong("Please choose dependent variable."), type = "error")
        return()
      }
      if (is.null(input$lm_indep) || length(input$lm_indep) < 1) {
        showNotification(strong("Please choose independent variable(s)."), type = "error")
        return()
      }
      req(lm_model_data())
      updateTabsetPanel(session, inputId = "lm_tabs", selected = "Test Result")

      output$lm_result <- renderPrint({
        df <- lm_model_data()
        main_effects <- input$lm_indep
        # If user picked interactions
        interaction_terms <- NULL
        if (!is.null(input$lm_interact) && length(input$lm_interact) > 0) {
          interaction_terms <- gsub(":", " * ", input$lm_interact)  # "A:B" -> "A * B"
        }
        rhs <- c(main_effects, interaction_terms)
        fml <- as.formula(paste(input$lm_dep, "~", paste(rhs, collapse = " + ")))
        lm(fml, data = df) %>%
          broom::tidy(conf.int = T) %>%
          dplyr::mutate(Sig = dplyr::case_when(
            is.na(p.value) ~ "",
            p.value < 0.001 ~ "***",
            p.value < 0.01 ~ "**",
            p.value < 0.05 ~ "*",
            TRUE ~ "NS"
          )) %>%
          knitr::kable(align = "c", format = "simple")
      })
    })


    # ---- LM: Check Assumptions and Show Diagnostic Plots ----
    observeEvent(input$lm_check, {
      if (is.null(input$lm_file)) {
        showNotification(strong("Please upload a data file."), type = "error")
        return()
      }
      if (is.null(input$lm_dep) || input$lm_dep == "") {
        showNotification(strong("Please choose dependent variable."), type = "error")
        return()
      }
      if (is.null(input$lm_indep) || length(input$lm_indep) < 1) {
        showNotification(strong("Please choose independent variable(s)."), type = "error")
        return()
      }
      req(lm_model_data())
      updateTabsetPanel(session, inputId = "lm_tabs", selected = "Assumptions")

      output$lm_assump <- renderPlot({
        df <- lm_model_data()
        main_effects <- input$lm_indep
        interaction_terms <- NULL
        if (!is.null(input$lm_interact) && length(input$lm_interact) > 0) {
          interaction_terms <- gsub(":", " * ", input$lm_interact)
        }
        rhs <- c(main_effects, interaction_terms)
        fml <- as.formula(paste(input$lm_dep, "~", paste(rhs, collapse = " + ")))
        mod <- lm(fml, data = df)
        performance::check_model(mod)
      })
    })

    # ---- LM: Apply Transformation to Dependent Variable ----
    lm_transformed_data <- reactive({
      req(lm_data(), input$lm_dep)
      df <- lm_data()
      y <- df[[input$lm_dep]]
      method <- input$lm_transform

      if (method == "none") {
        df[[input$lm_dep]] <- y
      } else if (method == "log") {
        if (any(y <= 0, na.rm = TRUE)) {
          showNotification(strong("Log transform requires all values > 0."), type = "error")
          return(NULL)
        }
        df[[input$lm_dep]] <- log(y)
      } else if (method == "yeojohnson") {
        df[[input$lm_dep]] <- bestNormalize::yeojohnson(y)$x.t
      } else if (method == "boxcox") {
        if (any(y <= 0, na.rm = TRUE)) {
          showNotification(strong("Box-Cox transform requires all values > 0."), type = "error")
          return(NULL)
        }
        df[[input$lm_dep]] <- bestNormalize::boxcox(y)$x.t
      } else if (method == "invnorm") {
        df[[input$lm_dep]] <- bestNormalize::orderNorm(y)$x.t
      }
      df
    })

    # ---- LM: Use Transformed Data for Modeling ----
    lm_model_data <- reactive({
      req(lm_transformed_data(), input$lm_dep, input$lm_indep)
      df <- lm_transformed_data()
      model_vars <- c(input$lm_dep, input$lm_indep)
      df <- df %>% dplyr::select(all_of(model_vars)) %>% tidyr::drop_na()
      if (input$lm_dep %in% input$lm_indep) {
        showNotification(strong("Dependent variable cannot be included as independent."), type = "error")
        return(NULL)
      }
      if (length(input$lm_indep) < 1) {
        showNotification(strong("Please select at least one independent variable."), type = "error")
        return(NULL)
      }
      df
    })

    # ---- Only Render Histogram When Button Clicked ----
    observe({
      shinyjs::hide("download_hist_before")
    })
    observeEvent(input$lm_check_norm, {
      if (is.null(input$lm_file)) {
        showNotification(strong("Please upload a data file."), type = "error")
        return()
      }
      if (is.null(input$lm_dep) || input$lm_dep == "") {
        showNotification(strong("Please choose dependent variable."), type = "error")
        return()
      }
      updateTabsetPanel(session, inputId = "lm_tabs", selected = "Dependent Variable Normality")

      output$lm_hist_before <- renderPlot({
        shinyjs::show("download_hist_before")
        req(lm_data(), input$lm_dep)
        df <- lm_data()
        ggplot(df, aes_string(input$lm_dep)) +
          geom_histogram(aes(y = after_stat(density)), color = "black", fill = "#4db6ac", bins = 30) +
          geom_density(color = "#b2182b", size = 1.2, alpha = 0.7, show.legend = FALSE) +
          theme_test() +
          labs(title = "Before Transformation", x = input$lm_dep, y = "Count")
      })

      output$lm_hist_after <- renderPlot({
        req(lm_transformed_data(), input$lm_dep)
        df <- lm_transformed_data()
        ggplot(df, aes_string(input$lm_dep)) +
          geom_histogram(aes(y = after_stat(density)), color = "black", fill = "#ffb74d", bins = 30) +
          geom_density(color = "#b2182b", size = 1.2, alpha = 0.7, show.legend = FALSE) +
          theme_test() +
          labs(title = "After Transformation", x = paste0(input$lm_dep, " (transformed)"), y = "Count")
      })
    })


    # # downlaod assumption as PDF
    output$lm_download_assump <- downloadHandler(
      filename = function() paste0("lm_assumption_plot_", Sys.Date(), ".pdf"),
      content = function(file) {
        df <- lm_model_data()
        main_effects <- input$lm_indep
        interaction_terms <- NULL
        if (!is.null(input$lm_interact) && length(input$lm_interact) > 0) {
          interaction_terms <- gsub(":", " * ", input$lm_interact)
        }
        rhs <- c(main_effects, interaction_terms)
        fml <- as.formula(paste(input$lm_dep, "~", paste(rhs, collapse = " + ")))
        mod <- lm(fml, data = df)
        p <- performance::check_model(mod)
        pdf(file, width = 13, height = 11)
        print(p)
        dev.off()
      },
      contentType = "application/pdf"
    )

    # Download handler for BEFORE transformation
    output$download_hist_before <- downloadHandler(
      filename = function() paste0("hist_before_", Sys.Date(), ".png"),
      content = function(file) {
        df <- lm_data()
        dep_var <- input$lm_dep
        png(file, width = 1200, height = 900, res = 150)
        print(
          ggplot(df, aes_string(dep_var)) +
            geom_histogram(aes(y = after_stat(density)), color = "black", fill = "#4db6ac", bins = 30) +
            geom_density(color = "#b2182b", size = 1.2, alpha = 0.7, show.legend = FALSE) +
            theme_test() +
            labs(title = "Before Transformation", x = dep_var, y = "Count")
        )
        dev.off()
      }
    )

    # Download handler for AFTER transformation
    output$download_hist_after <- downloadHandler(
      filename = function() paste0("hist_after_", Sys.Date(), ".png"),
      content = function(file) {
        req(lm_transformed_data(), input$lm_dep)
        df <- lm_transformed_data()
        png(file, width = 1200, height = 900, res = 150)
        print(
          ggplot(df, aes_string(input$lm_dep)) +
            geom_histogram(aes(y = after_stat(density)), color = "black", fill = "#ffb74d", bins = 30) +
            geom_density(color = "#b2182b", size = 1.2, alpha = 0.7, show.legend = FALSE) +
            theme_test() +
            labs(title = "After Transformation", x = paste0(input$lm_dep, " (transformed)"), y = "Density")
        )
        dev.off()
      }
    )

    # Render forest plot
    output$lm_effect <- renderPlot({
      req(lm_model_data(), input$lm_dep, input$lm_indep)
      df <- lm_model_data()
      main_effects <- input$lm_indep
      interaction_terms <- NULL
      if (!is.null(input$lm_interact) && length(input$lm_interact) > 0) {
        interaction_terms <- gsub(":", " * ", input$lm_interact)
      }
      rhs <- c(main_effects, interaction_terms)
      fml <- as.formula(paste(input$lm_dep, "~", paste(rhs, collapse = " + ")))
      mod <- lm(fml, data = df)
      library(sjPlot)
      b <- sjPlot::get_model_data(mod, type = "est")
      b %>%
        dplyr::mutate(group = dplyr::case_when(
          p.value < 0.05 & estimate > 0 ~ "sig_pos",
          p.value < 0.05 & estimate < 0 ~ "sig_neg",
          TRUE ~ "NS"
        )) %>%
        dplyr::filter(!is.na(conf.low), !is.na(conf.high)) %>%
        ggplot(aes(x = estimate, y = term)) +
        geom_vline(xintercept = 0, linetype = "dashed") +
        geom_errorbarh(aes(xmin = conf.low, xmax = conf.high), height = 0.11, size = 0.4, col = "black") +
        geom_point(aes(fill = group), color = "black", shape = 21, size = 2.5, alpha = 1, show.legend = FALSE) +
        scale_x_continuous(limits = ~ c(-max(abs(.x)), max(abs(.x))), expand = expansion(mult = 0.1)) +
        scale_fill_manual(values = c("sig_pos" = "#377EB8", "sig_neg" = "#E41A1C", "NS" = "white")) +
        labs(x = "Estimate (95% CI)", y = "") +
        theme_test() +
        theme(axis.text.x = element_text(size = 12, colour = "black"),
              axis.title.x = element_text(size = 14, face = "bold"),
              axis.text.y = element_text(size = 12, colour = "black"),
              axis.title.y = element_text(size = 14, face = "bold"))
    })

    # Automatically switch tab when “Plot Effects” is clicked
    observeEvent(input$lm_plot, {
      if (is.null(input$lm_file)) {
        showNotification(strong("Please upload a data file."), type = "error")
        return()
      }
      if (is.null(input$lm_dep) || input$lm_dep == "") {
        showNotification(strong("Please choose dependent variable."), type = "error")
        return()
      }
      if (is.null(input$lm_indep) || length(input$lm_indep) < 1) {
        showNotification(strong("Please choose independent variable(s)."), type = "error")
        return()
      }
      updateTabsetPanel(session, inputId = "lm_tabs", selected = "Effect Plot")
    })

    # download of the effect plot as PNG
    output$lm_download_effect <- downloadHandler(
      filename = function() paste0("lm_effect_plot_", Sys.Date(), ".png"),
      content = function(file) {
        req(lm_model_data(), input$lm_dep, input$lm_indep)
        df <- lm_model_data()
        main_effects <- input$lm_indep
        interaction_terms <- NULL
        if (!is.null(input$lm_interact) && length(input$lm_interact) > 0) {
          interaction_terms <- gsub(":", " * ", input$lm_interact)
        }
        rhs <- c(main_effects, interaction_terms)
        fml <- as.formula(paste(input$lm_dep, "~", paste(rhs, collapse = " + ")))
        mod <- lm(fml, data = df)
        b <- sjPlot::get_model_data(mod, type = "est") %>%
          dplyr::mutate(group = dplyr::case_when(
            p.value < 0.05 & estimate > 0 ~ "sig_pos",
            p.value < 0.05 & estimate < 0 ~ "sig_neg",
            TRUE ~ "NS"
          ))%>%
          dplyr::filter(!is.na(estimate), !is.na(conf.low), !is.na(conf.high))
        p <- ggplot(b, aes(x = estimate, y = term)) +
          geom_vline(xintercept = 0, linetype = "dashed") +
          geom_errorbarh(aes(xmin = conf.low, xmax = conf.high), height = 0.11, size = 0.4, col = "black") +
          geom_point(aes(fill = group), color = "black", shape = 21, size = 2.5, alpha = 1, show.legend = FALSE) +
          scale_x_continuous(limits = ~ c(-max(abs(.x)), max(abs(.x))), expand = expansion(mult = 0.1)) +
          scale_fill_manual(values = c("sig_pos" = "#377EB8", "sig_neg" = "#E41A1C", "NS" = "white")) +
          labs(x = "Estimate (95% CI)", y = "") +
          theme_test() +
          theme(axis.text.x = element_text(size = 12, colour = "black"),
                axis.title.x = element_text(size = 14, face = "bold"),
                axis.text.y = element_text(size = 12, colour = "black"),
                axis.title.y = element_text(size = 14, face = "bold"))
        ggsave(file, p, width = 7, height = 6, dpi = 600)
      }
    )

############################################################################################################
############################################################################################################
############################################################################################################
############################################################################################################

### ---------- Linear Mixed Effect Model -----------####

lmm_vars <- reactive({
  list(
    dep = input$lmm_dep,
    indep = input$lmm_indep,
    re = input$lmm_re
  )
})

    
    
    # ---- LMM: Dependent Variable UI ----
    output$lmm_dep_ui <- renderUI({
      req(input$lmm_file)
      df <- read.csv(input$lmm_file$datapath)
      num_vars <- names(df)[sapply(df, function(col) {
        is.numeric(col) &&
          length(unique(col)) > 10 &&
          any(col %% 1 != 0, na.rm = TRUE)  # exclude integer-only
      })]
      tagList(
        selectInput("lmm_dep", "Select dependent variable (continuous):",
                    choices = c("Select variable" = "", num_vars), selected = ""),
        tags$div(
          style = "color: #b2182b; font-size: 13px; font-weight: bold; margin-top: -10px; margin-bottom: 10px;",
          icon("info-circle", lib = "font-awesome"),
          "Only continuous variables are shown. Count or discrete variables are excluded, as they violate model assumptions. For count outcomes, please use the negative binomial option."
        )
      )
    })

    # ---- LMM: Independent Variables UI (exclude dependent) ----
    output$lmm_indep_ui <- renderUI({
      req(input$lmm_file)
      df <- read.csv(input$lmm_file$datapath)
      all_vars <- names(df)
      if (!is.null(input$lmm_dep) && nzchar(input$lmm_dep)) {
        all_vars <- setdiff(all_vars, input$lmm_dep)
      }
      selectizeInput("lmm_indep", "Select independent variables:",
                     choices = c("Select variable(s)" = "", all_vars), multiple = TRUE, selected = "")
    })

    # ---- LMM: Interaction Terms UI (no "None" option) ----
    output$lmm_interact_ui <- renderUI({
      req(input$lmm_file, input$lmm_indep)
      choices <- input$lmm_indep
      if (length(choices) < 2) {
        selectizeInput("lmm_interact", "Add interaction term(s):",
                       choices = c("No available interactions" = ""),
                       multiple = TRUE, selected = "", options = list(disabled = TRUE))
      } else {
        interact_choices <- combn(choices, 2, FUN = function(x) paste(x, collapse = ":"), simplify = TRUE)
        selectizeInput("lmm_interact", "Add interaction term(s):",
                       choices = c("None" = "", interact_choices),
                       multiple = TRUE, selected = NULL,
                       options = list(placeholder = "Select interaction(s)"))
      }
    })


    # ---- LMM: Random Effects UI ----

    observeEvent(list(input$lmm_file, input$lmm_indep), {
      req(input$lmm_file)
      df <- read.csv(input$lmm_file$datapath)
      fact_vars <- names(df)[sapply(df, function(x) is.factor(x) || is.character(x))]
      indep <- input$lmm_indep
      
      # Exclude independent variables from random effect choices
      choices <- setdiff(fact_vars, indep)
      
      # Preserve current selection if still valid
      current <- input$lmm_re
      still_valid <- intersect(current, choices)
      
      updateSelectizeInput(
        session,
        "lmm_re",
        choices = choices,
        selected = still_valid,
        options = list(placeholder = 'Select variable'),
        server = TRUE
      )
    })
    



    # ---- LMM: Dependent Variable Transformation UI ----
    output$lmm_transform_ui <- renderUI({
      req(input$lmm_file)
      selectInput(
        "lmm_transform",
        tagList(
          "Transform dependent variable (optional):",
          tags$span(icon("info-circle", id = "lmm_transform_info"),
                    style = "color: #2c3e50; font-size:16px; margin-left:5px;")
        ),
        choices = c(
          "None" = "none",
          "Log" = "log",
          "Yeo-Johnson" = "yeojohnson",
          "Box-Cox" = "boxcox",
          "Inverse Normal" = "invnorm"
        ),
        selected = "none"
      )
    })


    # ---- LMM: Load Data ----
    lmm_data <- reactive({
      req(input$lmm_file)
      tryCatch({
        read.csv(input$lmm_file$datapath, stringsAsFactors = TRUE)
      }, error = function(e) {
        showNotification(paste("Error reading file:", e$message), type = "error")
        NULL
      })
    })

    # ---- LMM: Get Current Variables ----
    lmm_dep_var      <- reactive({ input$lmm_dep })
    lmm_indep_vars   <- reactive({ input$lmm_indep })
    lmm_interact_terms <- reactive({ input$lmm_interact })
    lmm_random_vars  <- reactive({ input$lmm_re })
    lmm_transform    <- reactive({ input$lmm_transform })



    # Button logic: when clicked, show tab and render plots
    observe({
      shinyjs::hide("lmm_download_hist_before")
    })
    
    observeEvent(input$lmm_check_norm, {
      if (is.null(input$lmm_file)) {
        showNotification(strong("Please upload a data file."), type = "error")
        return()
      }
      if (is.null(input$lmm_dep) || input$lmm_dep == "") {
        showNotification(strong("Please choose dependent variable."), type = "error")
        return()
      }
      updateTabsetPanel(session, inputId = "lmm_tabs", selected = "Dependent Variable Normality")

      # Histogram BEFORE transformation
      output$lmm_hist_before <- renderPlot({
        shinyjs::show("lmm_download_hist_before")
        req(lmm_data(), input$lmm_dep)
        df <- lmm_data()
        ggplot(df, aes_string(input$lmm_dep)) +
          geom_histogram(aes(y = after_stat(density)), color = "black", fill = "#4db6ac", bins = 30) +
          geom_density(color = "#b2182b", size = 1.2, alpha = 0.7, show.legend = FALSE) +
          theme_test() +
          labs(title = "Before Transformation", x = input$lmm_dep, y = "Density")
      })

      shinyjs::hide("lmm_download_hist_before")
      
      # Histogram AFTER transformation
      output$lmm_hist_after <- renderPlot({
        shinyjs::show("lmm_download_hist_before")
        req(lmm_data(), input$lmm_dep)
        df <- lmm_data()
        x <- df[[input$lmm_dep]]
        trans_x <- switch(input$lmm_transform,
                          "log" = log(x[x > 0]),
                          "yeojohnson" = bestNormalize::yeojohnson(x)$x.t,
                          "boxcox" = bestNormalize::boxcox(x[x > 0])$x.t,
                          "invnorm" = bestNormalize::orderNorm(x)$x.t,
                          "none" = x)
        plot_df <- data.frame(val = trans_x)
        ggplot(plot_df, aes(val)) +
          geom_histogram(aes(y = after_stat(density)), color = "black", fill = "#ffb74d", bins = 30) +
          geom_density(color = "#b2182b", size = 1.2, alpha = 0.7, show.legend = FALSE) +
          theme_test() +
          labs(title = "After Transformation", x = paste0(input$lmm_dep, " (transformed)"), y = "Density")
      })
    })

    # Download logic
    output$lmm_download_hist_before <- downloadHandler(
      filename = function() paste0("lmm_hist_before_", Sys.Date(), ".png"),
      content = function(file) {
        req(lmm_data(), input$lmm_dep)
        df <- lmm_data()
        png(file, width = 1200, height = 900, res = 150)
        print(
          ggplot(df, aes_string(input$lmm_dep)) +
            geom_histogram(aes(y = after_stat(density)), color = "black", fill = "#4db6ac", bins = 30) +
            geom_density(color = "#b2182b", size = 1.2, alpha = 0.7, show.legend = FALSE) +
            theme_test() +
            labs(title = "Before Transformation", x = input$lmm_dep, y = "Density")
        )
        dev.off()
      }
    )
    output$lmm_download_hist_after <- downloadHandler(
      filename = function() paste0("lmm_hist_after_", Sys.Date(), ".png"),
      content = function(file) {
        req(lmm_data(), input$lmm_dep)
        df <- lmm_data()
        x <- df[[input$lmm_dep]]
        trans_x <- switch(input$lmm_transform,
                          "log" = log(x[x > 0]),
                          "yeojohnson" = bestNormalize::yeojohnson(x)$x.t,
                          "boxcox" = bestNormalize::boxcox(x[x > 0])$x.t,
                          "invnorm" = bestNormalize::orderNorm(x)$x.t,
                          "none" = x)
        plot_df <- data.frame(val = trans_x)
        png(file, width = 1200, height = 900, res = 150)
        print(
          ggplot(plot_df, aes(val)) +
            geom_histogram(aes(y = after_stat(density)), color = "black", fill = "#ffb74d", bins = 30) +
            geom_density(color = "#b2182b", size = 1.2, alpha = 0.7, show.legend = FALSE) +
            theme_test() +
            labs(title = "After Transformation", x = paste0(input$lmm_dep, " (transformed)"), y = "Density")
        )
        dev.off()
      }
    )

    # Optionally, disable the after-download button if "none" selected
    observe({
      if (is.null(input$lmm_transform) || input$lmm_transform == "none") {
        shinyjs::disable("lmm_download_hist_after")
      } else {
        shinyjs::enable("lmm_download_hist_after")
      }
    })


    # ---- Build LMM Formula String ----
    lmm_formula_string <- reactive({
      req(input$lmm_dep, input$lmm_indep, input$lmm_re)
      main <- input$lmm_indep[input$lmm_indep != input$lmm_dep]
      inter <- input$lmm_interact
      rhs <- c(main, inter)
      # Fixed effects
      fixed_part <- paste(rhs, collapse = " + ")
      if (fixed_part == "") fixed_part <- "1"
      # Random effects (allow nested/crossed, user can select multiple)
      re_terms <- sapply(input$lmm_re, function(x) paste0("(1|", x, ")"))
      formula_str <- paste(input$lmm_dep, "~", fixed_part, "+", paste(re_terms, collapse = " + "))
      formula_str
    })

    # ---- Final LMM Formula for Model ----
    lmm_formula <- reactive({
      as.formula(lmm_formula_string())
    })


    # ---- LMM: Assumptions Model, triggered by Check Assumptions button ----
    lmm_model_assump <- reactive({
        req(lmm_data(), input$lmm_dep, input$lmm_indep, input$lmm_re)
        df <- lmm_data()
        dep_var <- input$lmm_dep
        # Apply transformation
        trans_x <- switch(input$lmm_transform,
                          "log" = log(df[[dep_var]][df[[dep_var]] > 0]),
                          "yeojohnson" = bestNormalize::yeojohnson(df[[dep_var]])$x.t,
                          "boxcox" = bestNormalize::boxcox(df[[dep_var]][df[[dep_var]] > 0])$x.t,
                          "invnorm" = bestNormalize::orderNorm(df[[dep_var]])$x.t,
                          "none" = df[[dep_var]])
        df[[dep_var]] <- trans_x
        indep_vars <- setdiff(input$lmm_indep, dep_var)
        interaction_terms <- input$lmm_interact
        random_vars <- input$lmm_re

        rhs <- c(indep_vars, interaction_terms)
        fixed_formula <- paste(rhs, collapse = " + ")
        random_formula <- paste0("(1|", random_vars, ")", collapse = " + ")
        formula_string <- paste(dep_var, "~", fixed_formula, if (random_formula != "") paste("+", random_formula) else "")
        fml <- as.formula(formula_string)
        lmerTest::lmer(fml, data = df)
      })

      # ---- LMM: Check Assumptions and Show Diagnostic Plots ----
      observeEvent(input$lmm_check, {
        
        # Always clear the error output initially
        output$lmm_id_warning_msg_assump <- renderUI({ NULL })
        
        if (is.null(input$lmm_file)) {
          showNotification(strong("Please upload a data file."), type = "error")
          return()
        }
        if (is.null(input$lmm_dep) || input$lmm_dep == "") {
          showNotification(strong("Please choose dependent variable."), type = "error")
          return()
        }
        if (is.null(input$lmm_indep) || length(input$lmm_indep) < 1) {
          showNotification(strong("Please choose independent variable(s)."), type = "error")
          return()
        }
        if (is.null(input$lmm_re) || length(input$lmm_re) < 1) {
          showNotification(strong("Please choose random effect variable(s)."), type = "error")
          return()
        }
        
        # Always switch to the Assumptions tab first
        updateTabsetPanel(session, inputId = "lmm_tabs", selected = "Assumptions")
        
        # Check for identifier variable
        prob_vars <- lmm_id_col_problem()
        if (length(prob_vars) > 0) {
          output$lmm_id_warning_msg_assump <- renderUI({
            msg <- paste(
              "The following variable(s) appear to be identifiers (each value is unique):",
              paste(prob_vars, collapse = ", "),
              ". Using such columns as fixed effects will cause model failure. Please remove them from the independent variables. ",
              "Advice: Variables like patient ID, subject ID, or sample ID are not statistical predictors. Please remove them and try again."
            )
            div(
              style = "background-color:#f8d7da; color:#721c24; padding:14px; border:1px solid #f5c6cb; border-radius:5px; margin-bottom:12px;",
              icon("exclamation-circle", lib = "font-awesome"),
              strong(" Model Error: "),
              msg
            )
          })
          output$lmm_assump <- renderPlot(NULL) # Always clear the plot too!
          output$lmm_download_assump <- renderUI({ NULL }) 
          return()
        }
        
        # ---- ADD SINGLETON RANDOM EFFECT CHECK HERE ----
        df <- lmm_data()
        random_vars <- input$lmm_re
        singleton_re <- lmm_singleton_random_effect(df, random_vars)
        if (length(singleton_re) > 0) {
          output$lmm_id_warning_msg_assump <- renderUI({
            msg <- paste0(
              "The selected random effect variable (e.g., ", paste(singleton_re, collapse = ", "), 
              ") does not have repeated measurements (i.e., each level occurs only once). ",
              "Linear mixed models require repeated measurements for each grouping factor. ",
              "Please check your data or select another random effect."
            )
            div(
              style = "background-color:#fff3cd; color:#856404; padding:14px; border:1px solid #ffeeba; border-radius:5px; margin-bottom:12px;",
              icon("exclamation-triangle", lib = "font-awesome"),
              strong(" Model Error: "),
              msg
            )
          })
          output$lmm_assump <- renderPlot(NULL)
          output$lmm_download_assump <- renderUI({ NULL }) 
          return()
        }


      # Render diagnostic plots using performance::check_model
        output$lmm_assump <- renderPlot({
          req(lmm_model_assump())
          performance::check_model(lmm_model_assump())
        }, height = 750, width = 900)


      # Download handler for diagnostic plot (as PDF)
        output$lmm_download_assump <- downloadHandler(
          filename = function() paste0("lmm_assumption_plot_", Sys.Date(), ".pdf"),
          content = function(file) {
            pdf(file, width = 13, height = 11)
            print(performance::check_model(lmm_model_assump()))
            dev.off()
          },
          contentType = "application/pdf"
        )
      })

      # ---- LMM: Run LMM and Show Tidy Result ----
    lmm_model <- reactive({
      if (length(lmm_id_col_problem()) > 0) return(NULL)
      req(lmm_data(), input$lmm_dep, input$lmm_indep, input$lmm_re)
      df <- lmm_data()
      problem_vars <- input$lmm_indep[
        sapply(input$lmm_indep, function(var) length(unique(df[[var]])) == nrow(df))
      ]
      if (length(problem_vars) > 0) {
        stop("Identifier variable(s) in independent variables: ", paste(problem_vars, collapse = ", "))
      }
      dep_var <- input$lmm_dep
      trans_x <- switch(input$lmm_transform,
                        "log" = log(df[[dep_var]][df[[dep_var]] > 0]),
                        "yeojohnson" = bestNormalize::yeojohnson(df[[dep_var]])$x.t,
                        "boxcox" = bestNormalize::boxcox(df[[dep_var]][df[[dep_var]] > 0])$x.t,
                        "invnorm" = bestNormalize::orderNorm(df[[dep_var]])$x.t,
                        "none" = df[[dep_var]])
      df[[dep_var]] <- trans_x
      indep_vars <- setdiff(input$lmm_indep, dep_var)
      interaction_terms <- input$lmm_interact
      random_vars <- input$lmm_re

      rhs <- c(indep_vars, interaction_terms)
      fixed_formula <- paste(rhs, collapse = " + ")
      random_formula <- paste0("(1|", random_vars, ")", collapse = " + ")
      formula_string <- paste(dep_var, "~", fixed_formula, if (random_formula != "") paste("+", random_formula) else "")
      fml <- as.formula(formula_string)
      
      # Error handling
      model_or_error <- tryCatch({
        lmerTest::lmer(fml, data = df)
      }, error = function(e) {
        e
      })
      
      model_or_error
    })
    
    
    
    
    # Error
    lmm_id_col_problem <- reactive({
      req(lmm_data(), input$lmm_indep)
      df <- lmm_data()
      prob_vars <- input$lmm_indep[
        sapply(input$lmm_indep, function(var) length(unique(df[[var]])) == nrow(df))
      ]
      prob_vars
    })
    
    
    # message o
    lmm_id_error_message <- function(vars) {
      paste(
        "The following variable(s) appear to be identifiers (each value is unique):",
        paste(vars, collapse = ","),
        ". Using such columns as fixed effects will cause model failure. Please remove them from the independent variables."
      )
    }
    
    
    lmm_singleton_random_effect <- function(df, random_vars) {
      # Return vector of variable names with all unique values (no repeats)
      random_vars[sapply(random_vars, function(var) length(unique(df[[var]])) == nrow(df))]
    }
    
    
    
    
    # Error message
    output$lmm_warning_msg <- renderUI({
      model <- lmm_model()
      if (is.null(model)) return(invisible(NULL))
      if (inherits(model, "error")) {
        err_msg <- conditionMessage(model)
        if (grepl("number of levels of each grouping factor must be < number of observations", err_msg)) {
          div(
            style = "background-color:#fff3cd; color:#856404; padding:14px; border:1px solid #ffeeba; border-radius:5px; margin-bottom:12px;",
            icon("exclamation-triangle", lib = "font-awesome"),
            strong(" Model Error: "),
            "The selected random effect variable (e.g., Subject ID) does not have repeated measurements (i.e., each level occurs only once). Linear mixed models require repeated measurements for each grouping factor. Please check your data or select another random effect."
          )
        } else {
          div(
            style = "background-color:#f8d7da; color:#721c24; padding:14px; border:1px solid #f5c6cb; border-radius:5px; margin-bottom:12px;",
            icon("exclamation-circle", lib = "font-awesome"),
            strong(" Model Error: "),
            err_msg
          )
        }
      }
    })
    
    lmm_id_col_warning <- reactive({
      req(lmm_data(), input$lmm_indep)
      df <- lmm_data()
      problem_vars <- input$lmm_indep[
        sapply(input$lmm_indep, function(var) length(unique(df[[var]])) == nrow(df))
      ]
      if (length(problem_vars) > 0) {
        msg <- paste(
          "The following variable(s) appear to be identifiers (each value is unique in the data):",
          paste(problem_vars, collapse = ", "), 
          ". Using such columns as fixed effects will cause model failure. Please remove them from the independent variables."
        )
        return(msg)
      }
      return(NULL)
    })
    
    output$lmm_id_warning_msg <- renderUI({
      prob_vars <- lmm_id_col_problem()
      if (length(prob_vars) > 0) {
        msg <- paste(
          "The following variable(s) appear to be identifiers (each value is unique):",
          paste(prob_vars, collapse = ", "),
          ". Using such columns as fixed effects will cause model failure. Please remove them from the independent variables. ",
          "Advice: Variables like patient ID, subject ID, or sample ID are not statistical predictors. Please remove them and try again."
        )
        div(
          style = "background-color:#f8d7da; color:#721c24; padding:14px; border:1px solid #f5c6cb; border-radius:5px; margin-bottom:12px;",
          icon("exclamation-circle", lib = "font-awesome"),
          strong(" Model Error: "),
          msg
        )
      }
    })
    
    
    

    output$lmm_result <- renderPrint({
      df <- lmm_data()
      model <- lmm_model()
      if (is.null(model)) return(invisible(NULL))
      if (inherits(model, "error")) {
        return(invisible(NULL)) # Do not print anything
      }
      
      if ("infant_id" %in% input$lmm_indep) {
        unique_n <- length(unique(df$infant_id))
        nrows <- nrow(df)
        if (unique_n == nrows) {
          stop("infant_id cannot be used as a fixed effect if each level is unique.")
        }
      }
      
      # Only print tidy table if model succeeded
      broom.mixed::tidy(model, conf.int = TRUE) %>%
        dplyr::filter(effect == "fixed") %>%
        filter(!term %in% c("sd__(Intercept)", "sd__Observation")) %>%
        dplyr::select(-c(effect, group)) %>%
        dplyr::mutate(Sig = dplyr::case_when(
          is.na(p.value) ~ "",
          p.value < 0.001 ~ "***",
          p.value < 0.01 ~ "**",
          p.value < 0.05 ~ "*",
          TRUE ~ "NS"
        )) %>%
        knitr::kable(align = "c", format = "simple")
    })
    
    

      observeEvent(input$lmm_run, {
        if (is.null(input$lmm_file)) {
          showNotification(strong("Please upload a data file"), type = "error")
          return()
        }
        if (is.null(input$lmm_dep) || input$lmm_dep == "") {
          showNotification(strong("Please choose dependent variable."), type = "error")
          return()
        }
        if (is.null(input$lmm_indep) || length(input$lmm_indep) < 1) {
          showNotification(strong("Please choose independent variable(s)."), type = "error")
          return()
        }
        if (is.null(input$lmm_re) || length(input$lmm_re) < 1) {
          showNotification(strong("Please choose random effect variable(s)."), type = "error")
          return()
        }
        updateTabsetPanel(session, inputId = "lmm_tabs", selected = "Test Result")
      })

      # # Use kable for HTML
      # HTML(knitr::kable(out, align = "c", format = "html", table.attr='class="table table-condensed table-bordered table-striped"'))


      lmm_model_plot <- reactive({
        req(lmm_data(), input$lmm_dep, input$lmm_indep, input$lmm_re)
        df <- lmm_data()
        dep_var <- input$lmm_dep
        trans_x <- switch(input$lmm_transform,
                          "log" = log(df[[dep_var]][df[[dep_var]] > 0]),
                          "yeojohnson" = bestNormalize::yeojohnson(df[[dep_var]])$x.t,
                          "boxcox" = bestNormalize::boxcox(df[[dep_var]][df[[dep_var]] > 0])$x.t,
                          "invnorm" = bestNormalize::orderNorm(df[[dep_var]])$x.t,
                          "none" = df[[dep_var]])
        df[[dep_var]] <- trans_x
        indep_vars <- setdiff(input$lmm_indep, dep_var)
        interaction_terms <- input$lmm_interact
        random_vars <- input$lmm_re

        rhs <- c(indep_vars, interaction_terms)
        fixed_formula <- paste(rhs, collapse = " + ")
        random_formula <- paste0("(1|", random_vars, ")", collapse = " + ")
        formula_string <- paste(dep_var, "~", fixed_formula, if (random_formula != "") paste("+", random_formula) else "")
        fml <- as.formula(formula_string)
        lmerTest::lmer(fml, data = df)
      })


      

      observeEvent(input$lmm_plot, {
        output$lmm_id_warning_msg_effect <- renderUI({ NULL })
        if (is.null(input$lmm_file)) {
          showNotification(strong("Please upload a data file"), type = "error")
          return()
        }
        if (is.null(input$lmm_dep) || input$lmm_dep == "") {
          showNotification(strong("Please choose dependent variable."), type = "error")
          return()
        }
        if (is.null(input$lmm_indep) || length(input$lmm_indep) < 1) {
          showNotification(strong("Please choose independent variable(s)."), type = "error")
          return()
        }
        if (is.null(input$lmm_re) || length(input$lmm_re) < 1) {
          showNotification(strong("Please choose random effect variable(s)."), type = "error")
          return()
        }
        
        
        updateTabsetPanel(session, inputId = "lmm_tabs", selected = "Effect Plot")
        
        prob_vars <- lmm_id_col_problem()
        if (length(prob_vars) > 0) {
          output$lmm_id_warning_msg_effect <- renderUI({
            msg <- paste(
              "The following variable(s) appear to be identifiers (each value is unique):",
              paste(prob_vars, collapse = ", "),
              ". Using such columns as fixed effects will cause model failure. Please remove them from the independent variables. ",
              "Advice: Variables like patient ID, subject ID, or sample ID are not statistical predictors. Please remove them and try again."
            )
            div(
              style = "background-color:#f8d7da; color:#721c24; padding:14px; border:1px solid #f5c6cb; border-radius:5px; margin-bottom:12px;",
              icon("exclamation-circle", lib = "font-awesome"),
              strong(" Model Error: "),
              msg
            )
          })
          output$lmm_effect <- renderPlot(NULL) # Clear the plot if error
          output$lmm_download_effect <- renderUI({ NULL }) 
          return()
        }
        # ---- SINGLETON RANDOM EFFECT CHECK ----
        df <- lmm_data()
        random_vars <- input$lmm_re
        singleton_re <- lmm_singleton_random_effect(df, random_vars)
        if (length(singleton_re) > 0) {
          output$lmm_id_warning_msg_effect <- renderUI({
            msg <- paste0(
              "The selected random effect variable (e.g., ", paste(singleton_re, collapse = ", "), 
              ") does not have repeated measurements (i.e., each level occurs only once). ",
              "Linear mixed models require repeated measurements for each grouping factor. ",
              "Please check your data or select another random effect."
            )
            div(
              style = "background-color:#fff3cd; color:#856404; padding:14px; border:1px solid #ffeeba; border-radius:5px; margin-bottom:12px;",
              icon("exclamation-triangle", lib = "font-awesome"),
              strong(" Model Error: "),
              msg
            )
          })
          output$lmm_effect <- renderPlot(NULL)
          output$lmm_download_effect <- renderUI({ NULL }) 
          return()
        }
        
        # Render the plot of fixed effect estimates with CI and significance color
        output$lmm_effect <- renderPlot({
          req(lmm_model_plot())
          df <- broom.mixed::tidy(lmm_model_plot(), conf.int = TRUE) %>%
            dplyr::filter(effect == "fixed") %>%
            filter(!term %in% c("sd__(Intercept)", "sd__Observation")) %>%
            dplyr::select(-c(effect, group)) %>%
            dplyr::mutate(group = dplyr::case_when(
              p.value < 0.05 & estimate > 0 ~ "sig_pos",
              p.value < 0.05 & estimate < 0 ~ "sig_neg",
              TRUE ~ "NS"
            )) %>%
            dplyr::filter(term != "(Intercept)")
          ggplot(df, aes(x = estimate, y = term)) +
            geom_vline(xintercept = 0, linetype = "dashed") +
            geom_errorbarh(aes(xmin = conf.low, xmax = conf.high), height = 0.11, size = 0.4, col = "black") +
            geom_point(aes(fill = group), color = "black", shape = 21, size = 3, show.legend = FALSE) +
            scale_x_continuous(
              limits = ~ c(-max(abs(.x)), max(abs(.x))),
              expand = expansion(mult = 0.1)
            ) +
            scale_fill_manual(values = c("sig_pos" = "#377EB8", "sig_neg" = "#E41A1C", "NS" = "white")) +
            labs(
              x = "Estimate (95% CI)",
              y = ""
            ) +
            theme_test() +
            theme(axis.text.x = element_text(size = 12, colour = "black"),
                  axis.title.x = element_text(size = 14, face = "bold"),
                  axis.text.y = element_text(size = 12, colour = "black"))
        })
        
        output$lmm_download_effect <- renderUI({
          downloadButton("lmm_download_effect_real", "Download Effect Plot")
        })
        
      })


      # Download forest plot (LMM)
      # Inside observer, after all checks:
      output$lmm_download_effect <- renderUI({
        downloadButton("lmm_download_effect_real", "Download Effect Plot")
      })
      
      output$lmm_download_effect_real <- downloadHandler(
        filename = function() paste0("lmm_effect_plot_", Sys.Date(), ".png"),
        content = function(file) {
          req(lmm_model_plot())
          df <- broom.mixed::tidy(lmm_model_plot(), conf.int = TRUE) %>%
            dplyr::filter(effect == "fixed") %>%
            filter(!term %in% c("sd__(Intercept)", "sd__Observation")) %>%
            dplyr::select(-c(effect, group)) %>%
            dplyr::mutate(group = dplyr::case_when(
              p.value < 0.05 & estimate > 0 ~ "sig_pos",
              p.value < 0.05 & estimate < 0 ~ "sig_neg",
              TRUE ~ "NS"
            )) %>%
            dplyr::filter(term != "(Intercept)")
          p <- ggplot(df, aes(x = estimate, y = term)) +
            geom_vline(xintercept = 0, linetype = "dashed") +
            geom_errorbarh(aes(xmin = conf.low, xmax = conf.high), height = 0.11, size = 0.4, col = "black") +
            geom_point(aes(fill = group), color = "black", shape = 21, size = 3, show.legend = FALSE) +
            scale_x_continuous(
              limits = ~ c(-max(abs(.x)), max(abs(.x))),
              expand = expansion(mult = 0.1)
            ) +
            scale_fill_manual(values = c("sig_pos" = "#377EB8", "sig_neg" = "#E41A1C", "NS" = "white")) +
            labs(x = "Estimate (95% CI)", y = "") +
            theme_test() +
            theme(axis.text.x = element_text(size = 12, colour = "black"),
                  axis.title.x = element_text(size = 14, face = "bold"),
                  axis.text.y = element_text(size = 12, colour = "black"))
          ggsave(file, p, width = 7, height = 6, dpi = 600)
        }
      )
      

##############################################################################################################
##############################################################################################################
##############################################################################################################
##############################################################################################################
##############################################################################################################
##############################################################################################################
##############################################################################################################
##############################################################################################################

  ### ---------- Logistic regression -----------####

      log_data <- reactive({
        req(input$log_file)
        readr::read_csv(input$log_file$datapath, show_col_types = F)
      })


      # ---- Logistic Regression: UI for Dependent Variable ----
      output$log_dep_ui <- renderUI({
        df <- log_data()
        cat_vars <- names(df)[sapply(df, function(col) is.factor(col) || is.character(col))]
        tagList(
          selectInput("log_dep", "Select dependent variable (categorical):",
                      choices = c("Select variable" = "", cat_vars),
                      selected = ""),
          tags$div(
            style = "color: #b2182b; font-size: 13px; font-weight: bold; margin-top: -10px; margin-bottom: 10px;",
            icon("info-circle", lib = "font-awesome"),
            "Use a categorical dependent variable with exactly 2 levels. For more than 2, use multinomial regression."
          )
        )
      })

      # ---- Logistic Regression: UI for Independent Variables ----
      output$log_indep_ui <- renderUI({
        df <- log_data()
        all_vars <- names(df)
        choices <- setdiff(all_vars, input$log_dep)
        selectizeInput(
          "log_indep",
          "Select independent variables:",
          choices = choices,
          multiple = TRUE,
          selected = NULL,
          options = list(placeholder = "Select variable")
        )
      })

      # ---- Logistic Regression: Reset Independent Variable Choices When Dependent Changes ----
      observeEvent(input$log_dep, {
        df <- log_data()
        all_vars <- names(df)
        choices <- setdiff(all_vars, input$log_dep)
        updateSelectizeInput(session, "log_indep", choices = choices)
      })

      # ---- Logistic Regression: UI for Interactions ----
      output$log_interact_ui <- renderUI({
        req(input$log_indep)
        if (length(input$log_indep) < 2) return(NULL)

        combos <- combn(input$log_indep, 2, simplify = FALSE)
        interact_labels <- sapply(combos, function(x) paste(x, collapse = " : "))

        selectizeInput(
          "log_interact", "Add interaction term(s):",
          choices = setNames(sapply(combos, paste, collapse = ":"), interact_labels),
          multiple = TRUE, selected = NULL,
          options = list(placeholder = "Select interaction(s)")
        )
      })

      # ---- Logistic Regression: Run Model and Show Result Table with Interactions ----
      observeEvent(input$log_run, {
        if (is.null(input$log_file)) {
          showNotification(strong("Please upload a data file."), type = "error")
          return()
        }
        if (is.null(input$log_dep) || input$log_dep == "") {
          showNotification(strong("Please choose dependent variable."), type = "error")
          return()
        }
        if (is.null(input$log_indep) || length(input$log_indep) < 1) {
          showNotification(strong("Please choose independent variable(s)."), type = "error")
          return()
        }
        req(log_model_data())
        updateTabsetPanel(session, inputId = "log_tabs", selected = "Test Result")

        output$log_result <- renderPrint({
          df <- log_model_data()
          main_effects <- input$log_indep
          interaction_terms <- NULL
          if (!is.null(input$log_interact) && length(input$log_interact) > 0) {
            interaction_terms <- gsub(":", " * ", input$log_interact)
          }
          rhs <- c(main_effects, interaction_terms)
          fml <- as.formula(paste(input$log_dep, "~", paste(rhs, collapse = " + ")))
          
          warning_shown <- FALSE
          mod <- withCallingHandlers(
            glm(fml, data = df, family = binomial),
            warning = function(w) {
              if (grepl("fitted probabilities numerically 0 or 1", conditionMessage(w)) && !warning_shown) {
                showNotification(
                  div(
                    style = "background-color:#fff3cd; color:#856404; padding:14px; border:1px solid #ffeeba; border-radius:5px;",
                    icon("exclamation-triangle", lib = "font-awesome"),
                    strong("Model warning:"),
                    " Some variables in your data can perfectly predict the outcome. This can make the statistical results unreliable.",
                    br(),
                    "What you can do: Try removing variables or combining categories so no single variable always predicts the result."
                  ),
                  type = "warning"
                )
                warning_shown <<- TRUE
              }
              invokeRestart("muffleWarning")
            }
          )
          
          if (is.null(mod)) return(invisible(NULL))
          
          mod %>%
            broom::tidy(conf.int = TRUE) %>%
            dplyr::mutate(Sig = dplyr::case_when(
              is.na(p.value) ~ "",
              p.value < 0.001 ~ "***",
              p.value < 0.01 ~ "**",
              p.value < 0.05 ~ "*",
              TRUE ~ "NS"
            )) %>%
            knitr::kable(align = "c", format = "simple")
        })
        
      })

      # ---- Logistic Regression: Reactive for Final Model Data (checks and subset) ----
      log_model_data <- reactive({
        req(log_data(), input$log_dep, input$log_indep)
        df <- log_data()
        model_vars <- c(input$log_dep, input$log_indep)
        df <- df %>% dplyr::select(all_of(model_vars)) %>% tidyr::drop_na()

        if (input$log_dep %in% input$log_indep) {
          showNotification(strong("Dependent variable cannot be included as independent."), type = "error")
          return(NULL)
        }
        if (length(input$log_indep) < 1) {
          showNotification(strong("Please select at least one independent variable."), type = "error")
          return(NULL)
        }

        # ---- Recode dependent variable to 0/1 if binary factor ----
        df[[input$log_dep]] <- as.factor(df[[input$log_dep]])
        if (length(levels(df[[input$log_dep]])) != 2) {
          showNotification(strong("Dependent variable must have exactly 2 levels for logistic regression."), type = "error")
          return(NULL)
        }
        df[[input$log_dep]] <- as.numeric(df[[input$log_dep]]) - 1

        df
      })


      # ---- Logistic Regression: Check Assumptions and Show Diagnostic Plots ----
      observeEvent(input$log_check, {
        if (is.null(input$log_file)) {
          showNotification(strong("Please upload a data file."), type = "error")
          return()
        }
        if (is.null(input$log_dep) || input$log_dep == "") {
          showNotification(strong("Please choose dependent variable."), type = "error")
          return()
        }
        if (is.null(input$log_indep) || length(input$log_indep) < 1) {
          showNotification(strong("Please choose independent variable(s)."), type = "error")
          return()
        }
        req(log_model_data())
        updateTabsetPanel(session, inputId = "log_tabs", selected = "Assumptions")

        output$log_assump <- renderPlot({
          df <- log_model_data()
          main_effects <- input$log_indep
          interaction_terms <- NULL
          if (!is.null(input$log_interact) && length(input$log_interact) > 0) {
            interaction_terms <- gsub(":", " * ", input$log_interact)
          }
          rhs <- c(main_effects, interaction_terms)
          fml <- as.formula(paste(input$log_dep, "~", paste(rhs, collapse = " + ")))
          mod <- glm(fml, data = df, family = binomial)
          performance::check_model(mod)
        })
      })


      output$log_effect <- renderPlot({
        req(log_model_data(), input$log_dep, input$log_indep)
        df <- log_model_data()
        main_effects <- input$log_indep
        interaction_terms <- NULL
        if (!is.null(input$log_interact) && length(input$log_interact) > 0) {
          interaction_terms <- gsub(":", " * ", input$log_interact)
        }
        rhs <- c(main_effects, interaction_terms)
        fml <- as.formula(paste(input$log_dep, "~", paste(rhs, collapse = " + ")))
        mod <- glm(fml, data = df, family = binomial)

        # Use broom::tidy to get correct estimates + CI on log-odds scale
        b <- broom::tidy(mod, conf.int = TRUE) %>%
          dplyr::mutate(
            group = dplyr::case_when(
              p.value < 0.05 & estimate > 0 ~ "sig_pos",
              p.value < 0.05 & estimate < 0 ~ "sig_neg",
              TRUE ~ "NS"
            )
          ) %>%
          dplyr::filter(!is.na(conf.low), !is.na(conf.high)) %>%
          filter(term != "(Intercept)")

        if (nrow(b) == 0) {
          showNotification(strong("Effect plot could not be generated due to NA estimates or intervals."), 
                           type = "error")
          return(NULL)
        }

        xlim_val <- max(abs(c(b$conf.low, b$conf.high)), na.rm = TRUE)

        ggplot(b, aes(x = estimate, y = term)) +
          geom_vline(xintercept = 0, linetype = "dashed") +
          geom_errorbarh(aes(xmin = conf.low, xmax = conf.high), height = 0.11, size = 0.4, color = "black") +
          geom_point(aes(fill = group), color = "black", shape = 21, size = 2.5, show.legend = FALSE) +
          scale_x_continuous(limits = c(-xlim_val, xlim_val), expand = expansion(mult = 0.1)) +
          scale_fill_manual(values = c("sig_pos" = "#377EB8", "sig_neg" = "#E41A1C", "NS" = "white")) +
          labs(x = "Estimate (95% CI)", y = "") +
          theme_test() +
          theme(
            axis.text.x = element_text(size = 12, colour = "black"),
            axis.title.x = element_text(size = 14, face = "bold"),
            axis.text.y = element_text(size = 12, colour = "black"),
            axis.title.y = element_text(size = 14, face = "bold")
          )
      })

      # ---- Logistic Regression: Auto-switch to Effect Plot Tab ----
      observeEvent(input$log_plot, {
        if (is.null(input$log_file)) {
          showNotification(strong("Please upload a data file."), type = "error")
          return()
        }
        if (is.null(input$log_dep) || input$log_dep == "") {
          showNotification(strong("Please choose dependent variable."), type = "error")
          return()
        }
        if (is.null(input$log_indep) || length(input$log_indep) < 1) {
          showNotification(strong("Please choose independent variable(s)."), type = "error")
          return()
        }
        updateTabsetPanel(session, inputId = "log_tabs", selected = "Effect Plot")
      })

      # ---- Logistic Regression: Download Assumption Plot ----
      output$log_download_assump <- downloadHandler(
        filename = function() paste0("logistic_assumption_plot_", Sys.Date(), ".pdf"),
        content = function(file) {
          df <- log_model_data()
          main_effects <- input$log_indep
          interaction_terms <- NULL
          if (!is.null(input$log_interact) && length(input$log_interact) > 0) {
            interaction_terms <- gsub(":", " * ", input$log_interact)
          }
          rhs <- c(main_effects, interaction_terms)
          fml <- as.formula(paste(input$log_dep, "~", paste(rhs, collapse = " + ")))
          mod <- glm(fml, data = df, family = binomial)
          p <- performance::check_model(mod)
          pdf(file, width = 13, height = 11)
          print(p)
          dev.off()
        },
        contentType = "application/pdf"
      )

      # ---- Logistic Regression: Download Effect Plot ----
      output$log_download_effect <- downloadHandler(
        filename = function() paste0("logistic_effect_plot_", Sys.Date(), ".png"),
        content = function(file) {
          df <- log_model_data()
          main_effects <- input$log_indep
          interaction_terms <- NULL
          if (!is.null(input$log_interact) && length(input$log_interact) > 0) {
            interaction_terms <- gsub(":", " * ", input$log_interact)
          }
          rhs <- c(main_effects, interaction_terms)
          fml <- as.formula(paste(input$log_dep, "~", paste(rhs, collapse = " + ")))
          mod <- glm(fml, data = df, family = binomial)

          b <- broom::tidy(mod, conf.int = TRUE) %>%
            dplyr::filter(!is.na(conf.low), !is.na(conf.high), !is.na(estimate)) %>%
            dplyr::mutate(group = dplyr::case_when(
              p.value < 0.05 & estimate > 0 ~ "sig_pos",
              p.value < 0.05 & estimate < 0 ~ "sig_neg",
              TRUE ~ "NS"
            )) %>%
            dplyr::filter(!is.na(conf.low), !is.na(conf.high)) %>%
            filter(term != "(Intercept)")

          xlim_val <- max(abs(c(b$conf.low, b$conf.high)), na.rm = TRUE)

          p <- ggplot(b, aes(x = estimate, y = term)) +
            geom_vline(xintercept = 0, linetype = "dashed") +
            geom_errorbarh(aes(xmin = conf.low, xmax = conf.high), height = 0.11, size = 0.4, color = "black") +
            geom_point(aes(fill = group), color = "black", shape = 21, size = 2.5, show.legend = FALSE) +
            scale_x_continuous(limits = c(-xlim_val, xlim_val), expand = expansion(mult = 0.1)) +
            scale_fill_manual(values = c("sig_pos" = "#377EB8", "sig_neg" = "#E41A1C", "NS" = "white")) +
            labs(x = "Estimate (95% CI)", y = "") +
            theme_test() +
            theme(
              axis.text.x = element_text(size = 12, colour = "black"),
              axis.title.x = element_text(size = 14, face = "bold"),
              axis.text.y = element_text(size = 12, colour = "black"),
              axis.title.y = element_text(size = 14, face = "bold")
            )

          ggsave(file, p, width = 7, height = 6, dpi = 600)
        }
      )

##############################################################################################################
##############################################################################################################
##############################################################################################################
##############################################################################################################
##############################################################################################################
##############################################################################################################
##############################################################################################################
##############################################################################################################

      ### ---------- Negative binomial regression -----------####

      # ---- Negative Binomial: Reactive Data Upload ----
      nb_data <- reactive({
        req(input$nb_file)
        readr::read_csv(input$nb_file$datapath, show_col_types = F)
      })

      # ---- Negative Binomial: UI for Dependent Variable ----
      output$nb_dep_ui <- renderUI({
        df <- nb_data()
        count_like_vars <- names(df)[sapply(df, function(col) {
          is.numeric(col) && all(col >= 0, na.rm = TRUE) && all(col == floor(col), na.rm = TRUE)
        })]

        tagList(
          selectInput("nb_dep", "Select dependent variable (counts only):",
                      choices = c("Select variable" = "", count_like_vars),
                      selected = ""),
          tags$div(
            style = "color: #b2182b; font-size: 13px; font-weight: bold; margin-top: -10px; margin-bottom: 10px;",
            icon("info-circle", lib = "font-awesome"),
            "Only count data are shown. Continuous variables are excluded, as they violate model assumptions. For continuous outcomes, please use LM or LMM instead."
          )
        )
      })


      # ---- Negative Binomial: UI for Independent Variables ----
      output$nb_indep_ui <- renderUI({
        df <- nb_data()
        all_vars <- names(df)
        choices <- setdiff(all_vars, input$nb_dep)

        selectizeInput(
          "nb_indep",
          "Select independent variables:",
          choices = choices,
          multiple = TRUE,
          selected = NULL,
          options = list(placeholder = "Select variable")
        )
      })

      # ---- Negative Binomial: UI for Interactions ----
      output$nb_interact_ui <- renderUI({
        req(input$nb_indep)
        if (length(input$nb_indep) < 2) return(NULL)

        combos <- combn(input$nb_indep, 2, simplify = FALSE)
        interact_labels <- sapply(combos, function(x) paste(x, collapse = " : "))

        selectizeInput(
          "nb_interact", "Add interaction term(s):",
          choices = setNames(sapply(combos, paste, collapse = ":"), interact_labels),
          multiple = TRUE, selected = NULL,
          options = list(placeholder = "Select interaction(s)")
        )
      })

      # ---- Negative Binomial: Reactive for Final Model Data ----
      nb_model_data <- reactive({
        req(nb_data(), input$nb_dep, input$nb_indep)
        df <- nb_data()
        model_vars <- c(input$nb_dep, input$nb_indep)

        df <- df %>%
          dplyr::select(all_of(model_vars)) %>%
          tidyr::drop_na()

        if (input$nb_dep %in% input$nb_indep) {
          showNotification(strong("Dependent variable cannot be included as independent."), type = "error")
          return(NULL)
        }

        if (length(input$nb_indep) < 1) {
          showNotification(strong("Please select at least one independent variable."), type = "error")
          return(NULL)
        }

        df
      })


      # ---- Negative Binomial: Run Model and Show Result Table ----
      observeEvent(input$nb_run, {
        if (is.null(input$nb_file)) {
          showNotification(strong("Please upload a data file."), type = "error")
          return()
        }
        if (is.null(input$nb_dep) || input$nb_dep == "") {
          showNotification(strong("Please choose dependent variable."), type = "error")
          return()
        }
        if (is.null(input$nb_indep) || length(input$nb_indep) < 1) {
          showNotification(strong("Please choose independent variable(s)."), type = "error")
          return()
        }
        req(nb_model_data())
        updateTabsetPanel(session, inputId = "nb_tabs", selected = "Test Result")

        output$nb_result <- renderPrint({
          df <- nb_model_data()
          main_effects <- input$nb_indep
          interaction_terms <- NULL

          if (!is.null(input$nb_interact) && length(input$nb_interact) > 0) {
            interaction_terms <- gsub(":", " * ", input$nb_interact)  # "A:B" becomes "A * B"
          }

          rhs <- c(main_effects, interaction_terms)
          fml <- as.formula(paste(input$nb_dep, "~", paste(rhs, collapse = " + ")))

          MASS::glm.nb(fml, data = df) %>%
            broom::tidy(conf.int = TRUE) %>%
            dplyr::mutate(Sig = dplyr::case_when(
              is.na(p.value) ~ "",
              p.value < 0.001 ~ "***",
              p.value < 0.01 ~ "**",
              p.value < 0.05 ~ "*",
              TRUE ~ "NS"
            )) %>%
            knitr::kable(align = "c", format = "simple")
        })
      })

      # ---- Negative Binomial: Diagnostic Plot ----
      observeEvent(input$nb_check, {
        if (is.null(input$nb_file)) {
          showNotification(strong("Please upload a data file."), type = "error")
          return()
        }
        if (is.null(input$nb_dep) || input$nb_dep == "") {
          showNotification(strong("Please choose dependent variable."), type = "error")
          return()
        }
        if (is.null(input$nb_indep) || length(input$nb_indep) < 1) {
          showNotification(strong("Please choose independent variable(s)."), type = "error")
          return()
        }
        req(nb_model_data())
        updateTabsetPanel(session, inputId = "nb_tabs", selected = "Assumptions")

        output$nb_assump <- renderPlot({
          df <- nb_model_data()
          main_effects <- input$nb_indep
          interaction_terms <- NULL

          if (!is.null(input$nb_interact) && length(input$nb_interact) > 0) {
            interaction_terms <- gsub(":", " * ", input$nb_interact)
          }

          rhs <- c(main_effects, interaction_terms)
          fml <- as.formula(paste(input$nb_dep, "~", paste(rhs, collapse = " + ")))

          mod <- MASS::glm.nb(fml, data = df)
          performance::check_model(mod)
        })
      })

      # ---- Negative Binomial: Render Effect Plot (Manual) ----
      
      observeEvent(input$nb_plot, {
        if (is.null(input$nb_file)) {
          showNotification(strong("Please upload a data file."), type = "error")
          return()
        }
        if (is.null(input$nb_dep) || input$nb_dep == "") {
          showNotification(strong("Please choose dependent variable."), type = "error")
          return()
        }
        if (is.null(input$nb_indep) || length(input$nb_indep) < 1) {
          showNotification(strong("Please choose independent variable(s)."), type = "error")
          return()
        }
        req(nb_model_data())
        updateTabsetPanel(session, inputId = "nb_tabs", selected = "Effect Plot")
        
        output$nb_effect <- renderPlot({
          df <- nb_model_data()
          main_effects <- input$nb_indep
          interaction_terms <- NULL
          
          if (!is.null(input$nb_interact) && length(input$nb_interact) > 0) {
            interaction_terms <- gsub(":", " * ", input$nb_interact)
          }
          
          rhs <- c(main_effects, interaction_terms)
          fml <- as.formula(paste(input$nb_dep, "~", paste(rhs, collapse = " + ")))
          mod <- MASS::glm.nb(fml, data = df)
          
          b <- broom::tidy(mod, conf.int = TRUE) %>%
            dplyr::filter(!is.na(conf.low), !is.na(conf.high), !is.na(estimate)) %>%
            dplyr::mutate(group = dplyr::case_when(
              p.value < 0.05 & estimate > 0 ~ "sig_pos",
              p.value < 0.05 & estimate < 0 ~ "sig_neg",
              TRUE ~ "NS"
            )) %>%
            dplyr::filter(!is.na(conf.low), !is.na(conf.high)) %>%
            filter(term != "(Intercept)")
          
          ggplot(b, aes(x = estimate, y = term)) +
            geom_vline(xintercept = 0, linetype = "dashed") +
            geom_errorbarh(aes(xmin = conf.low, xmax = conf.high), height = 0.11, size = 0.4, color = "black") +
            geom_point(aes(fill = group), color = "black", shape = 21, size = 2.5, alpha = 1, show.legend = FALSE) +
            scale_x_continuous(limits = ~ c(-max(abs(.x)), max(abs(.x))), expand = expansion(mult = 0.1)) +
            scale_fill_manual(values = c("sig_pos" = "#377EB8", "sig_neg" = "#E41A1C", "NS" = "white")) +
            labs(x = "Estimate (95% CI)", y = "") +
            theme_test() +
            theme(
              axis.text.x = element_text(size = 12, colour = "black"),
              axis.title.x = element_text(size = 14, face = "bold"),
              axis.text.y = element_text(size = 12, colour = "black"),
              axis.title.y = element_text(size = 14, face = "bold")
            )
        })
      })
      

      # ---- Negative Binomial: Download Effect Plot ----
      output$nb_download_effect <- downloadHandler(
        filename = function() paste0("neg_binom_effect_plot_", Sys.Date(), ".png"),
        content = function(file) {
          df <- nb_model_data()
          main_effects <- input$nb_indep
          interaction_terms <- NULL

          if (!is.null(input$nb_interact) && length(input$nb_interact) > 0) {
            interaction_terms <- gsub(":", " * ", input$nb_interact)
          }

          rhs <- c(main_effects, interaction_terms)
          fml <- as.formula(paste(input$nb_dep, "~", paste(rhs, collapse = " + ")))
          mod <- MASS::glm.nb(fml, data = df)

          b <- broom::tidy(mod, conf.int = TRUE) %>%
            dplyr::filter(!is.na(conf.low), !is.na(conf.high), !is.na(estimate)) %>%
            dplyr::mutate(group = dplyr::case_when(
              p.value < 0.05 & estimate > 0 ~ "sig_pos",
              p.value < 0.05 & estimate < 0 ~ "sig_neg",
              TRUE ~ "NS"
            )) %>%
            dplyr::filter(!is.na(conf.low), !is.na(conf.high)) %>%
            filter(term != "(Intercept)")

          p <- ggplot(b, aes(x = estimate, y = term)) +
            geom_vline(xintercept = 0, linetype = "dashed") +
            geom_errorbarh(aes(xmin = conf.low, xmax = conf.high), height = 0.11, size = 0.4, color = "black") +
            geom_point(aes(fill = group), color = "black", shape = 21, size = 2.5, alpha = 1, show.legend = FALSE) +
            scale_x_continuous(limits = ~ c(-max(abs(.x)), max(abs(.x))), expand = expansion(mult = 0.1)) +
            scale_fill_manual(values = c("sig_pos" = "#377EB8", "sig_neg" = "#E41A1C", "NS" = "white")) +
            labs(x = "Estimate (95% CI)", y = "") +
            theme_test() +
            theme(
              axis.text.x = element_text(size = 12, colour = "black"),
              axis.title.x = element_text(size = 14, face = "bold"),
              axis.text.y = element_text(size = 12, colour = "black"),
              axis.title.y = element_text(size = 14, face = "bold")
            )

          ggsave(file, plot = p, width = 7, height = 6, dpi = 600)
        }
      )


      # ---- Negative Binomial: Download Assumption Plot as PDF ----
      output$nb_download_assump <- downloadHandler(
        filename = function() paste0("neg_binom_assumption_plot_", Sys.Date(), ".pdf"),
        content = function(file) {
          df <- nb_model_data()
          main_effects <- input$nb_indep
          interaction_terms <- NULL

          if (!is.null(input$nb_interact) && length(input$nb_interact) > 0) {
            interaction_terms <- gsub(":", " * ", input$nb_interact)
          }

          rhs <- c(main_effects, interaction_terms)
          fml <- as.formula(paste(input$nb_dep, "~", paste(rhs, collapse = " + ")))
          mod <- MASS::glm.nb(fml, data = df)

          p <- performance::check_model(mod)

          pdf(file, width = 13, height = 11)
          print(p)
          dev.off()
        },
        contentType = "application/pdf"
      )
##############################################################################################################
##############################################################################################################
##############################################################################################################
##############################################################################################################
##############################################################################################################
##############################################################################################################
##############################################################################################################
##############################################################################################################

      ### ---------- Multinomial regression -----------####

      # ---- Multinomial Regression: Reactive Data ----
      multi_data <- reactive({
        req(input$multi_file)
        readr::read_csv(input$multi_file$datapath, show_col_types = F)
      })


      # ---- Multinomial Regression: UI for Dependent Variable ----
      output$multi_dep_ui <- renderUI({
        df <- multi_data()
        cat_vars <- names(df)[sapply(df, function(col) is.factor(col) || is.character(col))]
        tagList(
          selectInput("multi_dep", "Select dependent variable (categorical):",
                      choices = c("Select variable" = "", cat_vars), selected = ""),
          tags$div(
            style = "color: #b2182b; font-size: 13px; font-weight: bold; margin-top: -10px; margin-bottom: 10px;",
            icon("info-circle", lib = "font-awesome"),
            "Use only categorical variables with 3 or more levels. For binary, use logistic regression instead."
          )
        )
      })


      # ---- Multinomial Regression: UI for Independent Variables ----
      output$multi_indep_ui <- renderUI({
        df <- multi_data()
        all_vars <- names(df)
        choices <- setdiff(all_vars, input$multi_dep)

        selectizeInput(
          "multi_indep",
          "Select independent variables:",
          choices = choices,
          multiple = TRUE,
          selected = NULL,
          options = list(placeholder = "Select variable")
        )
      })


      # ---- Multinomial Regression: UI for Interaction Terms ----
      output$multi_interact_ui <- renderUI({
        req(input$multi_indep)
        if (length(input$multi_indep) < 2) return(NULL)

        combos <- combn(input$multi_indep, 2, simplify = FALSE)
        interact_labels <- sapply(combos, function(x) paste(x, collapse = " : "))

        selectizeInput(
          "multi_interact", "Add interaction term(s):",
          choices = setNames(sapply(combos, paste, collapse = ":"), interact_labels),
          multiple = TRUE, selected = NULL,
          options = list(placeholder = "Select interaction(s)")
        )
      })


      # ---- Multinomial Regression: Run Model and Show Result Table ----
      observeEvent(input$multi_run, {
        if (is.null(input$multi_file)) {
          showNotification(strong("Please upload a data file."), type = "error")
          return()
        }
        if (is.null(input$multi_dep) || input$multi_dep == "") {
          showNotification(strong("Please choose dependent variable."), type = "error")
          return()
        }
        if (is.null(input$multi_indep) || length(input$multi_indep) < 1) {
          showNotification(strong("Please choose independent variable(s)."), type = "error")
          return()
        }
        req(multi_model_data())
        updateTabsetPanel(session, inputId = "multi_tabs", selected = "Test Result")

        output$multi_result <- renderPrint({
          df <- multi_model_data()
          main_effects <- input$multi_indep
          interaction_terms <- NULL

          if (!is.null(input$multi_interact) && length(input$multi_interact) > 0) {
            interaction_terms <- gsub(":", " * ", input$multi_interact)  # "A:B" -> "A * B"
          }

          rhs <- c(main_effects, interaction_terms)
          fml <- as.formula(paste(input$multi_dep, "~", paste(rhs, collapse = " + ")))
          mod <- nnet::multinom(fml, data = df, trace = FALSE)

          broom::tidy(mod, conf.int = TRUE) %>%
            dplyr::mutate(Sig = dplyr::case_when(
              is.na(p.value) ~ "",
              p.value < 0.001 ~ "***",
              p.value < 0.01 ~ "**",
              p.value < 0.05 ~ "*",
              TRUE ~ "NS"
            )) %>%
            knitr::kable(align = "c", format = "simple")
        })
      })

      # ---- Multinomial Regression: Reactive for Final Model Data ----
      multi_model_data <- reactive({
        req(multi_data(), input$multi_dep, input$multi_indep)
        df <- multi_data()
        model_vars <- c(input$multi_dep, input$multi_indep)
        df <- df %>% dplyr::select(all_of(model_vars)) %>% tidyr::drop_na()

        if (input$multi_dep %in% input$multi_indep) {
          showNotification(strong("Dependent variable cannot be included as independent."), type = "error")
          return(NULL)
        }

        if (length(input$multi_indep) < 1) {
          showNotification(strong("Please select at least one independent variable."), type = "error")
          return(NULL)
        }

        # Dependent must be a factor with 3+ levels
        df[[input$multi_dep]] <- as.factor(df[[input$multi_dep]])
        if (length(levels(df[[input$multi_dep]])) < 3) {
          showNotification(strong("Dependent variable must have 3 or more levels."), type = "error")
          return(NULL)
        }

        df
      })

      # ---- Multinomial Regression: Assumption Plot ----
      observeEvent(input$multi_check, {
        if (is.null(input$multi_file)) {
          showNotification(strong("Please upload a data file."), type = "error")
          return()
        }
        if (is.null(input$multi_dep) || input$multi_dep == "") {
          showNotification(strong("Please choose dependent variable."), type = "error")
          return()
        }
        if (is.null(input$multi_indep) || length(input$multi_indep) < 1) {
          showNotification(strong("Please choose independent variable(s)."), type = "error")
          return()
        }
        req(multi_model_data())
        updateTabsetPanel(session, inputId = "multi_tabs", selected = "Assumptions")
        
        output$multi_assump <- renderPlot({
          df <- multi_model_data()
          main_effects <- input$multi_indep
          interaction_terms <- NULL
          
          if (!is.null(input$multi_interact) && length(input$multi_interact) > 0) {
            interaction_terms <- gsub(":", " * ", input$multi_interact)
          }
          
          rhs <- c(main_effects, interaction_terms)
          fml <- as.formula(paste(input$multi_dep, "~", paste(rhs, collapse = " + ")))
          mod <- nnet::multinom(fml, data = df, trace = FALSE)
          performance::check_model(mod, residual_type = "normal")
        })
      })

      # ---- Multinomial Regression: Download Assumption Plot ----
      output$multi_download_assump <- downloadHandler(
        filename = function() paste0("multinomial_assumption_plot_", Sys.Date(), ".pdf"),
        content = function(file) {
          df <- multi_model_data()
          main_effects <- input$multi_indep
          interaction_terms <- NULL

          if (!is.null(input$multi_interact) && length(input$multi_interact) > 0) {
            interaction_terms <- gsub(":", " * ", input$multi_interact)
          }

          rhs <- c(main_effects, interaction_terms)
          fml <- as.formula(paste(input$multi_dep, "~", paste(rhs, collapse = " + ")))
          mod <- nnet::multinom(fml, data = df, trace = FALSE)

          check_plot <- performance::check_model(mod)

          pdf(file, width = 12, height = 9)
          print(check_plot)
          dev.off()
        },
        contentType = "application/pdf"
      )


} # end server

# ----- RUN APP -----
shinyApp(ui, server)
