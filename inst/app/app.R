library(shiny)
library(shinyjs)
library(bslib)
library(brglm2)
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
        
        /* Override just for Welch button */
        .btn-warning.welch-white {
        color: white !important;
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
      setTimeout(function() {
        // Remove existing tooltips
        $('[data-bs-toggle=\"tooltip\"]').tooltip('dispose');
        // Re-initialize tooltips
        var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle=\"tooltip\"]'));
        tooltipTriggerList.map(function(el) {
          return new bootstrap.Tooltip(el);
        });
      }, 200);
    });
  "))
    )
    ,
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
      .nav-tabs > li > a[data-value='Forest Plot'] {
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
    ),
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
            p("Many researchers misuse statistical tests by overlooking or misinterpreting key assumptions, which can lead to invalid conclusions.", strong("AssumpSure"), "guides users through assumption checks to ensure analyses are statistically sound, transparent, and ready for publication.", style = "color: #444; margin-top: 10px;
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
                            uiOutput("welch_result"),
                            uiOutput("welch_anova_result"),
                            uiOutput("test_result_with_square"),
                            uiOutput("welch_boxplot_ui"),
                            uiOutput("posthoc_ui"),
                            uiOutput("posthoc_result_ui"),
                            br(),
                            conditionalPanel(
                              condition = "input.test_type != 'welch_test' && input.test_type != 'welch_anova'",
                              uiOutput("boxplot_ui")
                            )
                   )
                 )
               )
             )
           )
  ),

  tabPanel("Fisher & Chi-square",
           fluidPage(
             useShinyjs(),
             sidebarLayout(
               sidebarPanel(
                 fileInput("file_fisher", "Upload CSV File", accept = ".csv"),
                 uiOutput("fisher_timepoint_ui"),
                 uiOutput("cat1_ui"),
                 uiOutput("cat2_ui"),
                 uiOutput("test_type_fisher_ui"),
                 actionButton("run_fisher", "Run Test", class = "btn-success"),
                 actionButton("plot_fisher", "Plot", class = "btn-primary")
               ),
               mainPanel(
                 uiOutput("fisher_chisq_result"),
                 uiOutput("fisher_chisq_square"),
                 br(),
                 uiOutput("posthoc_method_ui"),
                 uiOutput("posthoc_result_fisher"),
                 uiOutput("dynamic_fisher_plot"),
                 uiOutput("dynamic_download_fisher"),
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
                            uiOutput("lm_transform_ui"),
                            actionButton("lm_check_norm", "Check Dependent Variable Normality",
                                         class = "btn-warning"),
                            tags$div(style = "margin-top: 5px;"),
                            actionButton("lm_run", "Run LM", class = "btn-success"),
                            tags$div(style = "margin-top: 5px;"),
                            actionButton("lm_check", "Check Assumptions", class = "btn-primary"),
                            tags$div(style = "margin-top: 5px;"),
                            actionButton("lm_plot", "Plot Forest", class = "btn-info")
                          ),
                          mainPanel(
                            tabsetPanel(
                              id = "lm_tabs",
                              tabPanel("Dependent Variable Normality",
                                       fluidRow(column(6,
                                                plotOutput("lm_hist_before"),
                                                uiOutput("lm_shapiro_square_before"),
                                                downloadButton("download_hist_before", "Download Before")),
                                                column(6, uiOutput("lm_hist_after_ui"),
                                                       uiOutput("shapiro_square_after")))),
                              tabPanel("Test Result", uiOutput("lm_result")),
                              tabPanel("Assumptions",
                                       uiOutput("note_title_lm"),
                                       plotOutput("lm_assump", height = "700px"),
                                       br(),
                                       downloadButton("lm_download_assump", "Download Assumption Plot")),
                              tabPanel("Forest Plot",
                                       plotOutput("lm_effect", height = "550px", width = "600px"),
                                       br(),
                                       downloadButton("lm_download_effect", "Download Forest Plot"))
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
                            uiOutput("lmm_re_ui"),
                            uiOutput("lmm_transform_ui"),
                            actionButton("lmm_check_norm", "Check Dependent Variable Normality",
                                         class = "btn-warning"),
                            tags$div(style = "margin-top: 5px;"),
                            actionButton("lmm_run", "Run LMM", class = "btn-success"),
                            tags$div(style = "margin-top: 5px;"),
                            actionButton("lmm_check", "Check Assumptions", class = "btn-primary"),
                            tags$div(style = "margin-top: 5px;"),
                            actionButton("lmm_plot", "Plot Forest", class = "btn-info")
                          ),
                          mainPanel(
                            tabsetPanel(
                              id = "lmm_tabs",
                              tabPanel("Dependent Variable Normality",
                                       fluidRow(
                                         column(6,
                                                plotOutput("lmm_hist_before"),
                                                uiOutput("lmm_shapiro_square_before"),
                                                downloadButton("lmm_download_hist_before", "Download Before")),
                                         column(6, uiOutput("lmm_hist_after_ui"
                                                )))),
                              tabPanel("Test Result", 
                                       uiOutput("lmm_warning_msg"),
                                       uiOutput("lmm_id_warning_msg"),
                                       uiOutput("lmm_result")),
                              tabPanel("Assumptions",
                                       uiOutput("note_title_lmm"),
                                       uiOutput("lmm_id_warning_msg_assump"),
                                       plotOutput("lmm_assump", height = "700px"),
                                       br(),
                                       br(),
                                       br(),
                                       downloadButton("lmm_download_assump", "Download Assumption Plot")
                              ),
                              tabPanel("Forest Plot",
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
                            actionButton("log_plot", "Plot Forest", class = "btn-info")
                          ),
                          mainPanel(
                            tabsetPanel(
                              id = "log_tabs",
                              tabPanel("Test Result", uiOutput("log_result")),
                              tabPanel("Assumptions",
                                       uiOutput("note_title_log"),
                                       plotOutput("log_assump", height = "700px"),
                                       br(),
                                       downloadButton("log_download_assump", "Download Assumption Plot")),
                              tabPanel("Forest Plot",
                                       plotOutput("log_effect", height = "550px", width = "600px"),
                                       br(),
                                       downloadButton("log_download_effect", "Download Forest Plot"))
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
                              tabPanel("Test Result", uiOutput("multi_result")),
                              tabPanel("Assumptions",
                                       uiOutput("note_title_mult"),
                                       plotOutput("multi_assump", height = "700px"),
                                       br(),
                                       downloadButton("multi_download_assump", "Download Assumption Plot"))
                            )
                          )
                        )
                      )
             ),
             tabPanel("Poisson Regression",
                      fluidPage(
                        titlePanel("Poisson Regression"),
                        sidebarLayout(
                          sidebarPanel(
                            fileInput("poiss_file", "Upload CSV File", accept = ".csv"),
                            uiOutput("poiss_dep_ui"),
                            uiOutput("poiss_indep_ui"),
                            uiOutput("poiss_interact_ui"),
                            actionButton("poiss_run", "Run Poisson", class = "btn-success"),
                            tags$div(style = "margin-top: 5px;"),
                            actionButton("poiss_check", "Check Assumptions", class = "btn-primary"),
                            tags$div(style = "margin-top: 5px;"),
                            actionButton("poiss_plot", "Plot Forest", class = "btn-info")
                          ),
                          mainPanel(
                            tabsetPanel(
                              id = "poiss_tabs",
                              tabPanel("Test Result", uiOutput("poiss_result")),
                              tabPanel("Assumptions",
                                       uiOutput("poiss_overdisp_ui"), 
                                       uiOutput("note_title_poiss"),  
                                       plotOutput("poiss_assump", height = "700px"),
                                       br(),
                                       downloadButton("poiss_download_assump", "Download Assumption Plot")),
                              tabPanel("Forest Plot",
                                       plotOutput("poiss_effect", height = "550px", width = "600px"),
                                       br(),
                                       downloadButton("poiss_download_effect", "Download Forest Plot")
                              )
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
                            actionButton("nb_plot", "Plot Forest", class = "btn-info")
                          ),
                          mainPanel(
                            tabsetPanel(
                              id = "nb_tabs",
                              tabPanel("Test Result", uiOutput("nb_result")),
                              tabPanel("Assumptions",
                                       uiOutput("nb_zeroinfl_ui"),
                                       uiOutput("note_title_nb"),
                                       plotOutput("nb_assump", height = "700px"),
                                       br(),
                                       downloadButton("nb_download_assump", "Download Assumption Plot")),
                              tabPanel("Forest Plot",
                                       plotOutput("nb_effect", height = "550px", width = "600px"),
                                       br(),
                                       downloadButton("nb_download_effect", "Download Forest Plot"))
                            )
                          )
                        )
                      )
             ),
             tabPanel("Zero-Inflated Negative Binomial",
                      fluidPage(
                        titlePanel("Zero-Inflated Negative Binomial Regression"),
                        sidebarLayout(
                          sidebarPanel(
                            fileInput("zinb_file", "Upload CSV File", accept = ".csv"),
                            uiOutput("zinb_dep_ui"),
                            uiOutput("zinb_indep_ui"),
                            uiOutput("zinb_interact_ui"),
                            actionButton("zinb_run", "Run ZINB", class = "btn-success"),
                            tags$div(style = "margin-top: 5px;"),
                            actionButton("zinb_check", "Check Assumptions", class = "btn-primary"),
                            tags$div(style = "margin-top: 5px;"),
                            actionButton("zinb_plot", "Plot Forest", class = "btn-info")
                          ),
                          mainPanel(
                            tabsetPanel(
                              id = "zinb_tabs",
                              tabPanel("Test Result", uiOutput("zinb_result")),
                              tabPanel("Assumptions",
                                       uiOutput("note_title_zinb"),
                                       plotOutput("zinb_assump", height = "700px"),
                                       br(),
                                       downloadButton("zinb_download_assump", "Download Assumption Plot")),
                              tabPanel("Forest Plot",
                                       plotOutput("zinb_effect", height = "550px", width = "600px"),
                                       br(),
                                       downloadButton("zinb_download_effect", "Download Forest Plot"))
                            )
                          )
                        )
                      )
             ),
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
                     conditionalPanel(
                       condition = "!output.cor_too_many_features",
                       uiOutput("cor_table_title"), 
                       uiOutput("cor_result_content"),
                       uiOutput("cor_table_ui"),
                       uiOutput("heatmap_error"),
                       uiOutput("cor_heatmap_ui"),
                       uiOutput("cor_download_heatmap_ui"),
                       uiOutput("cor_matrix_download_ui"),
                       uiOutput("cor_download_table_ui")
                     ),
                     conditionalPanel(
                       condition = "output.cor_too_many_features",
                       div(
                         style="color:#a00; font-weight:bold; margin-top:18px;",
                         icon("exclamation-triangle", lib="font-awesome"),
                         "Correlation results, plots, downloads, and tooltips are disabled for >100 features. Please use the slider or manual selection to reduce the number of features and then click on 'Run Correlation' button."
                       )
                     )
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

      p(strong("AssumpSure"), "supports a wide range of parametric and nonparametric tests, including:", style = "color: #444; margin-top: 10px;"),

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
                 tags$li(icon("dot-circle", style = "color: #3A9BB2; margin-right: 10px;"), "Poisson & Negative Binomial Regression"),
                 tags$li(icon("dot-circle", style = "color: #3A9BB2; margin-right: 10px;"), "Correlation analyses")
               )
        )
      ),

      hr(),


      # How to Choose the Right Test
      h4(icon("question-circle", style = "margin-right: 8px; color: #F2E099;"),
         "How to Choose the Right Test",
         style = "color: #2c3e50; font-weight: 600;"),

      p("Not sure which test to run? Start with these simple rules based on your data type.", strong("AssumpSure"), "will recommend the most appropriate test if your initial choice is not suitable.",
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
          "If your dependent variable is a count (e.g., number of visits, gene reads): use ", strong("Poisson Regression")
        ),

        tags$li(
          icon("check-circle", style = "color: #3A9BB2; margin-right: 8px;"),
          "If you're examining the relationship between two continuous variables: use a ", strong("Correlation test (Pearson, Spearman, etc.)")
        ),

        tags$li(
          icon("check-circle", style = "color: #3A9BB2; margin-right: 8px;"),
          "If you have two categorical variables (e.g., treatment and response):"
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
        tags$li("Ensure the data is in long format, not wide format."),
        tags$li("Always check the tooltips for the best guidance."),
        tags$li("Ensure timepoint is correctly labeled as 'timepoint' for longitudinal models.")
      ),

      hr(),
  
  # Developer Info
  h4(icon("user", style = "margin-right: 8px; color: #E3A599;"), "Developer",
     style = "color: #2c3e50; font-weight: 600;"),
  
  p(
    HTML('This app was developed by <strong>Ahmed Bargheet, PhD</strong>.'),
    style = "color: #444; text-align: left; margin-top: 10px;"
  ),
  
  hr(),

      # Contact Info
  h4(icon("envelope", style = "margin-right: 8px; color: #E3A599;"), "Need Help?",
     style = "color: #2c3e50; font-weight: 600;"),

  p(
    HTML('For feedback, questions, or bug reports, please contact me <a href="mailto:ahmed.bargheet@yahoo.com" style="color: #3A9BB2; text-decoration: underline;">HERE</a>.'),
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
      # Let read_csv guess column types (remove col_types=.default="c")
      df <- readr::read_csv(
        input$file$datapath,
        show_col_types = FALSE,
        na = c("", "NA", "N/A", "null")
      )
      
      # Convert character columns to factor if they have <=50 unique values,
      # otherwise leave as character. Numeric columns left as is.
      # df[] <- lapply(df, function(col) {
      #   if (is.character(col) && length(unique(col)) <= 50) {
      #     return(factor(col))
      #   } else if (is.logical(col)) {
      #     return(factor(col))
      #   } else {
      #     return(col)
      #   }
      # })
      
      df[] <- lapply(df, function(col) {
        if (is.character(col) && length(unique(col)) <= 50) {
          factor(col)
        } else if (is.logical(col)) {
          factor(col)
        } else if (is.numeric(col) && all(col == floor(col), na.rm = TRUE) && length(unique(col)) <= 10) {
          as.character(col)   # numeric-coded categorical → character
        } else {
          col
        }
      })
      
      
      # Warn if dataset is too small
      if (nrow(df) < 10) {
        showNotification(strong("Warning: The app only detects continuous variables with ≥10 observations and ≥5 distinct values. This is the minimum for detection; reliable statistics usually need ≥20–30 observations per group."), type = "warning", duration = 15)
      }
      
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
    # Final, production-ready replacement
    # Returns names of continuous variables meeting data sufficiency and spread criteria.
    get_continuous_vars <- function(df,
                                    min_n = 10,          # minimum finite observations
                                    min_unique = 5,     # minimum distinct finite values
                                    exclude_pure_integers = TRUE,
                                    fractional_tol = sqrt(.Machine$double.eps)) {
      
      # Fast unique counter
      unique_count <- function(x) {
        if (requireNamespace("data.table", quietly = TRUE)) data.table::uniqueN(x) else length(unique(x))
      }
      
      is_continuous <- function(col) {
        if (!is.numeric(col)) return(FALSE)
        
        x <- col[is.finite(col)]
        if (length(x) < min_n) return(FALSE)
        
        v <- stats::var(x)
        if (is.na(v) || v <= 0) return(FALSE)
        
        if (unique_count(x) < min_unique) return(FALSE)
        
        if (exclude_pure_integers && all(abs(x - round(x)) <= fractional_tol)) return(FALSE)
        
        TRUE
      }
      
      keep <- vapply(df, is_continuous, logical(1L))
      names(df)[keep]
    }
    
    # Drop-in replacement for your line:
    numeric_vars <- get_continuous_vars(df)
    
    
    
    
    # Categorical: factor or character with few unique values
    cat_vars <- names(df)[sapply(df, function(col) {
      is.factor(col) || (is.character(col) && length(unique(col)) <= 10)
    })]
    
    tagList(
      selectInput("value_col",
                  tagList(
                    "Select Numeric Value Column (continuous):",
                    tags$span(
                      icon("info-circle", class = "fa-solid"),
                      `data-bs-toggle` = "tooltip",
                      `data-bs-placement` = "right",
                      title = "Note: Only continuous variables are displayed. Count or discrete variables are excluded because they violate the normality and homogeneity assumptions of t-tests and ANOVA. For count outcomes, please use the Poisson regression (under 'Regression Models tab')."
                    )),
                  choices = c("Choose" = "", numeric_vars)),
      selectInput("group_col", 
                  tagList(
                  "Select Group/Condition Column (categorical):",
                  tags$span(
                    icon("info-circle", class = "fa-solid"),
                    `data-bs-toggle` = "tooltip",
                    `data-bs-placement` = "right",
                    title = "Note: Categorical variables are limited to 10 levels to ensure ANOVA and Kruskal–Wallis results remain reliable and interpretable, with adequate samples per group."
                  )),
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
  welch_clicked <- reactiveVal(FALSE)
  welch_anova_clicked <- reactiveVal(FALSE)
  
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
          v1 <- df %>% dplyr::filter(group == group_levels[1]) %>% pull(value)
          v2 <- df %>% dplyr::filter(group == group_levels[2]) %>% pull(value)
          n <- min(length(v1), length(v2))
          if (n < 3) stop("Not enough data in one or both groups.")
          diff <- v1[1:n] - v2[1:n]
          shapiro_diff <- rstatix::shapiro_test(diff)
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
    
    # Define when the buttons should be shown
    show_buttons <- TRUE
    
    if (test_type %in% c("mannwhitney", "wilcoxon_signed")) {
      if (ngroups != 2) show_buttons <- FALSE
    }
    
    if (test_type == "kruskal" && ngroups < 3) {
      show_buttons <- FALSE
    }
    
    if (!assumptions_met()) show_buttons <- FALSE
    if (!should_show_test_result()) show_buttons <- FALSE
    
    if (show_buttons) {
      shinyjs::enable("plot_boxplot")
      shinyjs::show("plot_boxplot")
      shinyjs::enable("download_boxplot")
      shinyjs::show("download_boxplot")
    } else {
      shinyjs::disable("plot_boxplot")
      shinyjs::hide("plot_boxplot")
      shinyjs::disable("download_boxplot")
      shinyjs::hide("download_boxplot")
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

  
  # reset Welch ANOVA
  observeEvent(input$file, { welch_anova_clicked(FALSE) })
  observeEvent(input$test_type, { welch_anova_clicked(FALSE) })
  observeEvent(input$value_col, { welch_anova_clicked(FALSE) })
  observeEvent(input$group_col, { welch_anova_clicked(FALSE) })
  
  
  
  # Reset everything when the user changes anything
  reset_results <- function() {
    output$test_result_with_square <- renderUI({ NULL })
    output$boxplot <- renderPlot({ NULL })
    output$actual_test_result <- renderUI({ NULL })
    output$posthoc_result <- renderUI({ NULL })
    output$posthoc_result_ui <- renderUI({ NULL })
    run_test_clicked(FALSE)
  }

  # Show the post hoc results area only when button is pressed
  observeEvent(input$run_posthoc, {
    output$posthoc_result_ui <- renderUI({
      uiOutput("posthoc_result")
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
    #group_is_numeric <- is.numeric(type.convert(df0[[input$group_col]], as.is = TRUE))
    group_is_numeric <- is.numeric(df0[[input$group_col]])
    

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
      dplyr::mutate(value = as.numeric(as.character(value)),
             group = as.factor(group)) %>%
      dplyr::filter(!is.na(value), !is.na(group)) %>%
      droplevels()
    # New: Minimum checks
    ngroups <- nlevels(df$group)
    group_sizes <- table(df$group)
    if (input$test_type == "independent_ttest") {
      if (ngroups < 2) {
        showNotification(strong("Only one group detected. Independent t-test requires exactly two groups."), type = "error")
        return()
      }
      if (ngroups > 2) {
        showNotification(strong("More than two groups detected. Please use One-way ANOVA. Independent t-test is only for comparing exactly two groups."), type = "error", duration = 9)
        return()
      }
      if (any(group_sizes < 2)) {
        showNotification(strong("Each group must have at least two observations for independent t-test."), type = "error")
        return()
      }
    }
    if (input$test_type == "dependent_ttest") {
      counts <- table(df$group)
      ngroups <- length(counts)
      group_sizes <- as.numeric(counts)
      
      if (ngroups < 2) {
        showNotification(strong("Only one group detected. Paired t-test requires exactly two groups."), type = "error", duration = 5)
        return()
      }
      if (ngroups > 2) {
        showNotification(strong("More than two groups detected. Please use One-way ANOVA. Paired t-test is only for comparing exactly two groups."), type = "error", duration = 9)
        return()
      }
      if (length(unique(group_sizes)) > 1) {
        showNotification(strong("Paired t-test requires both groups to have equal sample size. If your data are not truly paired, consider using the independent t-test. Otherwise, check your data for missing or unmatched pairs."), type = "error", duration = 9)
        return()
      }
      if (any(group_sizes < 3)) {
        showNotification(strong("Paired t-test requires at least 3 samples in each group."), type = "error", 
                         duration = 3)
        return()
      }
    }
    
    
    # ---- ANOVA GROUP CHECK ----
    if (input$test_type == "anova") {
      ngroups <- nlevels(df$group)
      
      if (ngroups == 1) {
        showNotification(
          strong("Only one group detected. One-way ANOVA requires three or more groups."), 
          type = "error", 
          duration = 9
        )
        return()
      }
      
      if (ngroups == 2) {
        showNotification(
          strong("Only two groups detected. Please use a t-test (independent or paired, as appropriate). One-way ANOVA is for three or more groups."), 
          type = "error", 
          duration = 9
        )
        return()
      }
    }
    
    processed_data(df)
  })

  
  observeEvent(input$file, { welch_clicked(FALSE) })
  observeEvent(input$check_assumptions, { welch_clicked(FALSE) })
  
  
  
  

 # Run the Post hoc test
  observeEvent(input$run_posthoc, {
    df <- processed_data()
    method <- input$posthoc_method
    
    # Check for missing or empty selection BEFORE running any test
    if (is.null(method) || method == "") {
      msg <- if (input$test_type == "anova") {
        strong("Please choose Tukey HSD or a p-value correction method.")
      } else if (input$test_type == "kruskal") {
        strong("Please choose a p-value correction method.")
      } else {
        strong("Please choose a post hoc method.")
      }
      showNotification(msg, type = "error")
      output$posthoc_result <- renderUI({ NULL })
      return()
    }
    if (is.null(df)) return()

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

    
    
    output$posthoc_result <- renderUI({
      if (is.null(posthoc)) return(NULL)
      
      tbl_post <- posthoc %>%
        knitr::kable(align = "c", format = "html") %>%
        kableExtra::kable_styling(bootstrap_options = c("hover", "condensed", "bordered"), 
                                  position = "left") %>%
        kableExtra::scroll_box(width = "100%", height = "100%")
      
      # Compute pairwise effect size
      effsize_tbl <- NULL
      pairs <- unique(posthoc[, c("group1", "group2")])
      
      if (nrow(pairs) > 0 && all(c("group1", "group2") %in% names(pairs))) {
        effsize_list <- lapply(1:nrow(pairs), function(i) {
          g1 <- as.character(pairs$group1[i])
          g2 <- as.character(pairs$group2[i])
          dat <- subset(processed_data(), group %in% c(g1, g2))
          dat$group <- droplevels(dat$group)
          tryCatch({
            if (input$test_type == "anova") {
              rstatix::cohens_d(value ~ group, data = dat, paired = FALSE)
            } else if (input$test_type == "kruskal") {
              rstatix::wilcox_effsize(value ~ group, data = dat, paired = FALSE)
            } else {
              NULL
            }
          }, error = function(e) NULL)
        })
        effsize_tbl <- dplyr::bind_rows(effsize_list) %>%
          knitr::kable(format = "html", align = "c") %>%
          kableExtra::kable_styling(bootstrap_options = c("hover", "condensed", "bordered"), 
                                    position = "left", full_width = TRUE) %>%
          kableExtra::scroll_box(width = "100%", height = "100%")
      }
      
      tagList(
        div(style = "margin-top: 15px;", HTML(tbl_post)),
        if (!is.null(effsize_tbl)) {
          tagList(
            tags$h5(style = "margin-top: 20px;", strong("Effect size (Wilcoxon r, unpaired)")),
            div(style = "margin-top: 8px;", HTML(effsize_tbl))
          )
        }
      )
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
    h4(strong("Assumption Test Results")),
    div(
      h5(strong("Levene's Test (Equal Variance)")),
      div(style = "background-color: #fcfcfc; padding: 10px; border-radius: 5px;",
          uiOutput("levene_text")),
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
      h5(strong("Shapiro-Wilk Test (Normality)")),
      div(style = "background-color: #fcfcfc; padding: 10px; border-radius: 5px;",
          uiOutput("shapiro_text")),
      if (!is.na(shap_p[1]))
        div(
          style = paste0("background-color: ", if (shap_failed) "#B20D00" else "green",
                         "; color: white; padding: 10px; border-radius: 5px; margin-top: 10px;"),
          strong(
            if (shap_failed)
              "One or more groups deviate significantly from normality."
            else
              "Data appears to be normally distributed"
          )
        )
    ),
    br(),
    h4(strong("Diagnostic Plots")),
    fluidRow(
      column(6, plotOutput("qq_plot"),
             div(
               style = "display: flex; align-items: center;",
               downloadButton("download_qq", "Download Q-Q Plot", class = "no-print"),
               tags$span(
                 icon("info-circle", class = "fa-solid"),
                 `data-bs-toggle` = "tooltip",
                 `data-bs-placement` = "right",
                 title = "If the points in the Q-Q plot fall close to the diagonal line, the data are likely normally distributed. Large or systematic deviations from the line indicate the data are not normal.",
                 class = "no-print",
                 style = "margin-left:8px; color: black; cursor: pointer;"
               )
             )
      ),
      column(6,
        plotOutput("histogram_plot"),
        div(
          style = "display: flex; align-items: center;",
          downloadButton("download_histogram", "Download Histogram", class = "no-print"),
          tags$span(
            icon("info-circle", class = "fa-solid"),
            `data-bs-toggle` = "tooltip",
            `data-bs-placement` = "right",
            title = "A normal distribution appears as a bell-shaped, symmetrical histogram. Noticeable skew or multiple peaks indicate the data are likely not normally distributed.",
            class = "no-print",
            style = "margin-left:8px; color: black; cursor: pointer;"
          )))
    ),
    br(),
    h4(strong("Assumption Check Summary")),
    uiOutput("assumption_summary")
  )
}

# Dependent t-test
assumption_ui_dependent <- function() {
  shap_res <- shapiro_result()
  shap_p <- if (!is.null(shap_res) && "p.value" %in% names(shap_res)) shap_res$p.value[1] else NA
  tagList(
    br(),
    h4(strong("Assumption Test Results (Paired T-test)")),
    div(
      h5(strong("Shapiro-Wilk Test (Normality of Differences)")),
      div(style = "background-color: #fcfcfc; padding: 10px; border-radius: 5px;",
          uiOutput("shapiro_text")),
      if (is.numeric(shap_p) && !is.na(shap_p) && length(shap_p) == 1)
        div(
          style = paste0("background-color: ", if (shap_p <= 0.05) "#B20D00" else "green",
                         "; color: white; padding: 10px; border-radius: 5px; margin-top: 10px;"),
          strong(
            if (shap_p <= 0.05)
              "Differences are not normally distributed."
            else
              "Differences appear to be normally distributed"
          )
        )
    ),
    br(),
    h4(strong("Diagnostic Plots")),
    fluidRow(
      column(6, plotOutput("qq_plot"),
             div(
               style = "display: flex; align-items: center;",
               downloadButton("download_qq", "Download Q-Q Plot", class = "no-print"),
               tags$span(
                 icon("info-circle", class = "fa-solid"),
                 `data-bs-toggle` = "tooltip",
                 `data-bs-placement` = "right",
                 title = "If the points in the Q-Q plot fall close to the diagonal line, the data are likely normally distributed. Large or systematic deviations from the line indicate the data are not normal.",
                 class = "no-print",
                 style = "margin-left:8px; color: black; cursor: pointer;"
               )
             )
      ),
      column(6,
             plotOutput("histogram_plot"),
             div(
               style = "display: flex; align-items: center;",
               downloadButton("download_histogram", "Download Histogram", class = "no-print"),
               tags$span(
                 icon("info-circle", class = "fa-solid"),
                 `data-bs-toggle` = "tooltip",
                 `data-bs-placement` = "right",
                 title = "A normal distribution appears as a bell-shaped, symmetrical histogram. Noticeable skew or multiple peaks indicate the data are likely not normally distributed.",
                 class = "no-print",
                 style = "margin-left:8px; color: black; cursor: pointer;"
               )))
    ),
    br(),
    h4(strong("Assumption Check Summary")),
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
    h4(strong("Assumption Test Results")),
    div(
      h5(strong("Levene's Test (Equal Variance)")),
      div(style = "background-color: #fcfcfc; padding: 10px; border-radius: 5px;",
          uiOutput("levene_text")),
      if (!is.na(lev_p))
        div(
          style = paste0("background-color: ", if (lev_p <= 0.05) "#B20D00" else "green",
                         "; color: white; padding: 10px; border-radius: 5px; margin-top: 10px;"),
          strong(
            if (lev_p <= 0.05)
              "Variances are significantly different (Heterogeneous)."
            else
              "Variances are equal (Homogeneous)"
          )
        )
    ),
    div(
      br(),
      h5(strong("Shapiro-Wilk Test (Normality)")),
      div(style = "background-color: #fcfcfc; padding: 10px; border-radius: 5px;",
          uiOutput("shapiro_text")),
      if (!is.na(shap_p[1]))
        div(
          style = paste0("background-color: ", if (shap_failed) "#B20D00" else "green",
                         "; color: white; padding: 10px; border-radius: 5px; margin-top: 10px;"),
          strong(
            if (shap_failed)
              "One or more groups deviate significantly from normality."
            else
              "Data appears to be normally distributed"
          )
        )
    ),
    br(),
    h4(strong("Diagnostic Plots")),
    {
      lev_res <- levene_result()
      shap_res <- shapiro_result()
      has_check_error <- is.null(lev_res) || is.null(shap_res)
      if (!has_check_error) {
        fluidRow(
          column(6, plotOutput("qq_plot"),
                 div(
                   style = "display: flex; align-items: center;",
                   downloadButton("download_qq", "Download Q-Q Plot", class = "no-print"),
                   tags$span(
                     icon("info-circle", class = "fa-solid"),
                     `data-bs-toggle` = "tooltip",
                     `data-bs-placement` = "right",
                     title = "If the points in the Q-Q plot fall close to the diagonal line, the data are likely normally distributed. Large or systematic deviations from the line indicate the data are not normal.",
                     class = "no-print",
                     style = "margin-left:8px; color: black; cursor: pointer;"
                   )
                 )
          ),
          column(6,
                 plotOutput("histogram_plot"),
                 div(
                   style = "display: flex; align-items: center;",
                   downloadButton("download_histogram", "Download Histogram", class = "no-print"),
                   tags$span(
                     icon("info-circle", class = "fa-solid"),
                     `data-bs-toggle` = "tooltip",
                     `data-bs-placement` = "right",
                     title = "A normal distribution appears as a bell-shaped, symmetrical histogram. Noticeable skew or multiple peaks indicate the data are likely not normally distributed.",
                     class = "no-print",
                     style = "margin-left:8px; color: black; cursor: pointer;"
                   )))
        )
      } else {
        div(style = "color: #b00; margin: 10px 0;",
            "Diagnostic plots are not available because the assumption checks could not be performed (missing or invalid data).")
      }
    },
    br(),
    h4(strong("Assumption Check Summary")),
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
  print(df %>% dplyr::group_by(group) %>% rstatix::shapiro_test(value))
}

# Dependent t-test
shapiro_text_dependent <- function(df) {
  group_levels <- levels(df$group)
  if (length(group_levels) != 2) {
    cat("Error: Need exactly 2 groups for paired test.")
    return()
  }
  values1 <- df %>% dplyr::filter(group == group_levels[1]) %>% pull(value)
  values2 <- df %>% dplyr::filter(group == group_levels[2]) %>% pull(value)
  if (length(values1) != length(values2) || length(values1) < 3) {
    cat("Cannot run paired test: Unequal or insufficient values per group. Check your data.")
    return()
  }
  diff <- values1 - values2
  print(rstatix::shapiro_test(diff))
}

# ANOVA
shapiro_text_anova <- function(df) {
  print(df %>% dplyr::group_by(group) %>% rstatix::shapiro_test(value))
}

# shapiro_text_anova <- function(df) { ... }



# --- Refactored Shapiro Output renderPrint ---
output$shapiro_text <- renderUI({
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
  #knitr::kable(shap, align = "c", "simple")
  #HTML(knitr::kable(shap, align = "c", format = "html", table.attr='class="table table-condensed table-bordered table-striped"'))
  
  tbl <- knitr::kable(shap, format = "html", align = "c")
  tbl <- tbl %>%
    kableExtra::kable_styling(
      bootstrap_options = c("hover", "condensed", "bordered"),
      position = "center", full_width = T)
  HTML(tbl)
  
})


# Levene test
## independent t-test
output$levene_text <- renderUI({
  lev <- levene_result()
  if (is.null(lev)) return(NULL)
  #knitr::kable(lev, align = "c", "simple")
  
  tbl_lev <- knitr::kable(lev, format = "html", align = "c")  # Center columns
  tbl_lev <- kableExtra::kable_styling(tbl_lev, 
                                       bootstrap_options = c("hover", "condensed", "bordered"), 
                                   position = "center", full_width = T)
  HTML(tbl_lev)
})


  # --- QQ Plot ---
# independent t-test
  qq_plot_independent <- function(df) {
    ggplot2::ggplot(df, aes(sample = value, color = group)) +
      stat_qq() +
      stat_qq_line(color = "#E41A1C") +
      theme_test() +
      scale_color_brewer(palette = "Set2") +
      facet_wrap(~group) +
      theme(strip.text = element_text(size = 12, face = "bold", color = "black")) + 
      theme(strip.background = element_rect(colour = "black", fill = "white")) +
      theme(axis.title.x = element_text(colour = "black", face="bold", size = 12)) +
      theme(axis.title.y = element_text(colour = "black", face="bold", size = 12)) + 
      theme(axis.text.x = element_text(colour = "black", size = 10)) +
      theme(axis.text.y = element_text(colour = "black", size = 10)) +
      xlab("Theoretical Quantiles") + 
      ylab("Sample Quantiles") + 
      theme(legend.position = "none") +
      theme(plot.background = element_rect(fill = "white"))
  }

# Dependent t-test
  qq_plot_dependent <- function(df) {
    group_levels <- levels(df$group)
    if (length(group_levels) != 2) return()
    v1 <- df %>% dplyr::filter(group == group_levels[1]) %>% pull(value)
    v2 <- df %>% dplyr::filter(group == group_levels[2]) %>% pull(value)
    if (length(v1) != length(v2) || length(v1) < 3) return()
    diff <- v1 - v2
    ggplot2::ggplot(data.frame(diff = diff), aes(sample = diff)) +
      stat_qq(color = "#66C2A5") +
      stat_qq_line(color = "#E41A1C") +
      theme_test() +
      scale_color_brewer(palette = "Set2") +
      scale_fill_brewer(palette = "Set2") +
      theme(axis.title.x = element_text(colour = "black", face="bold", size = 12)) +
      theme(axis.title.y = element_text(colour = "black", face="bold", size = 12)) +
      theme(axis.text.x = element_text(colour = "black", size = 10)) +
      theme(axis.text.y = element_text(colour = "black", size = 10)) +
      xlab("Theoretical Quantiles") + 
      ylab("Sample Quantiles") + 
      theme(legend.position = "none") +
      labs(title = "Q-Q Plot of Differences") +
      theme(plot.background = element_rect(fill = "white"))
  }


  # One-way ANOVA
  qq_plot_anova <- function(df) {
    df <- df %>% dplyr::filter(!is.na(group))
    df$group <- droplevels(factor(df$group))
    n_groups <- nlevels(df$group)
    
    # Choose palette: Set2 up to 8 groups, otherwise default hues
    if (n_groups <= 8) {
      pal_color <- ggplot2::scale_color_brewer(palette = "Set2")
    } else {
      cols <- scales::hue_pal()(n_groups)
      pal_color <- ggplot2::scale_color_manual(values = cols)
    }
    
    ggplot2::ggplot(df, ggplot2::aes(sample = value, color = group)) +
      ggplot2::stat_qq() +
      ggplot2::stat_qq_line(color = "#E41A1C") +
      ggplot2::theme_test() +
      pal_color +
      ggplot2::facet_wrap(~group) +
      ggplot2::theme(strip.text = ggplot2::element_text(size = 12, face = "bold", color = "black"),
                     strip.background = ggplot2::element_rect(colour = "black", fill = "white"),
                     axis.title.x = ggplot2::element_text(colour = "black", face = "bold", size = 12),
                     axis.title.y = ggplot2::element_text(colour = "black", face = "bold", size = 12),
                     axis.text.x  = ggplot2::element_text(colour = "black", size = 10),
                     axis.text.y  = ggplot2::element_text(colour = "black", size = 10),
                     legend.position = "none",
                     plot.background = ggplot2::element_rect(fill = "white")) +
      ggplot2::xlab("Theoretical Quantiles") + 
      ggplot2::ylab("Sample Quantiles")
  }



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
    ggplot2::ggplot(df, aes(x = value, fill = group, colour = group)) +
      geom_histogram(aes(y = after_stat(density)), bins = 30, color = "black", alpha = 0.7) +
      geom_density(color = "#b2182b", size = 1.2, alpha = 0.7, show.legend = FALSE) +
      theme_test() +
      scale_color_brewer(palette = "Set2") +
      scale_fill_brewer(palette = "Set2") +
      facet_wrap(~group) + 
      theme(strip.text = element_text(size = 12, face = "bold",color = "black")) + 
      theme(strip.background = element_rect(colour = "black", fill = "white")) + 
      theme(axis.title.x = element_text(colour = "black", face="bold", size = 12)) +
      theme(axis.title.y = element_text(colour = "black", face="bold", size = 12)) + 
      theme(axis.text.x = element_text(colour = "black", size = 10)) +
      theme(axis.text.y = element_text(colour = "black", size = 10)) +
      xlab("Value") + 
      ylab("Density") +
      theme(legend.position = "none") +
      theme(plot.background = element_rect(fill = "white"))
  }

# Dependent t-test
  histogram_plot_dependent <- function(df) {
    group_levels <- levels(df$group)
    if (length(group_levels) != 2) return()
    v1 <- df %>% dplyr::filter(group == group_levels[1]) %>% pull(value)
    v2 <- df %>% dplyr::filter(group == group_levels[2]) %>% pull(value)
    if (length(v1) != length(v2) || length(v1) < 3) return()
    diff <- v1 - v2
    ggplot2::ggplot(data.frame(diff = diff), aes(x = diff)) +
      geom_histogram(aes(y = after_stat(density)), bins = 30, color = "black", 
                     fill = "#66C2A5", alpha = 0.7) +
      geom_density(color = "#b2182b", fill = "#66C2A5", size = 1.2, alpha = 0.7, show.legend = FALSE) +
      theme_test() +
      scale_color_brewer(palette = "Set2") + 
      scale_fill_brewer(palette = "Set2") +
      theme(axis.title.x = element_text(colour = "black", face="bold", size = 12)) +
      theme(axis.title.y = element_text(colour = "black", face="bold", size = 12)) + 
      theme(axis.text.x = element_text(colour = "black", size = 10)) +
      theme(axis.text.y = element_text(colour = "black", size = 10)) +
      xlab("Value") + 
      ylab("Density") +
      labs(title = "Histogram of Differences") +
      theme(plot.background = element_rect(fill = "white"))
  }

  # One-way ANOVA
  histogram_plot_anova <- function(df) {
    df <- df %>% dplyr::filter(!is.na(group))
    df$group <- droplevels(factor(df$group))
    n_groups <- nlevels(df$group)
    
    # Choose palette: Set2 up to 8 groups, otherwise default ggplot hues
    if (n_groups <= 8) {
      pal_fill  <- ggplot2::scale_fill_brewer(palette = "Set2")
      pal_color <- ggplot2::scale_color_brewer(palette = "Set2")
    } else {
      cols <- scales::hue_pal()(n_groups)
      pal_fill  <- ggplot2::scale_fill_manual(values = cols)
      pal_color <- ggplot2::scale_color_manual(values = cols)
    }
    
    ggplot2::ggplot(df, ggplot2::aes(x = value, fill = group, colour = group)) +
      ggplot2::geom_histogram(ggplot2::aes(y = after_stat(density)), bins = 30, color = "black", alpha = 0.7) +
      ggplot2::geom_density(color = "#b2182b", size = 1.2, alpha = 0.7, show.legend = FALSE) +
      ggplot2::theme_test() +
      pal_color + pal_fill +
      ggplot2::facet_wrap(~group) +
      ggplot2::theme(strip.text = ggplot2::element_text(size = 12, face = "bold", color = "black"),
                     strip.background = ggplot2::element_rect(colour = "black", fill = "white"),
                     axis.title.x = ggplot2::element_text(colour = "black", face = "bold", size = 12),
                     axis.title.y = ggplot2::element_text(colour = "black", face = "bold", size = 12),
                     axis.text.x  = ggplot2::element_text(colour = "black", size = 10),
                     axis.text.y  = ggplot2::element_text(colour = "black", size = 10),
                     legend.position = "none",
                     plot.background = ggplot2::element_rect(fill = "white")) +
      ggplot2::xlab("Value") + 
      ggplot2::ylab("Density")
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
      ggsave(file, plot = p, width = 7, height = 4, dpi = 600, bg = "white")
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
    levene <- levene_result()
    normality_p <- if ("p" %in% names(normality)) normality$p else NA
    variance_p <- if ("p" %in% names(levene)) levene$p else NA
    variance_passed <- !is.na(variance_p) && variance_p > 0.05
    min_n <- min(table(df$group))
    
    # Case 1: All assumptions met and n >= 10
    if (all(!is.na(normality_p)) && all(normality_p > 0.10) && variance_passed && !is.na(min_n) && min_n >= 10) {
      return(div(
        style = "background-color: green; color: white; padding: 10px; border-radius: 5px;",
        strong("✓ Assumptions Passed"),
        p("Parametric independent t-test can be performed with confidence.")
      ))
    }
    
    # Case 2: Normal, variance OK, but small sample size (<10)
    if (all(!is.na(normality_p)) && all(normality_p > 0.10) && variance_passed && !is.na(min_n) && min_n < 10) {
      return(div(
        style = "background-color: #ffc107; color: black; padding: 10px; border-radius: 5px;",
        strong("! Normality assumed but small sample size"),
        p("Normality and variance assumptions are met, but at least one group has < 10 observations. Normality tests are unreliable with small samples. Please, check QQ plot and histogram. When uncertain, use the ", strong("Mann-Whitney U test."))
      ))
    }
    
    # Case 3: Assumptions not met (either non-normality or both failed)
    failed_normality <- any(!is.na(normality_p) & normality_p <= 0.05)
    failed_variance <- !is.na(variance_p) && variance_p <= 0.05
    if (failed_normality || (failed_normality && failed_variance)) {
      return(div(
        style = "background-color: #B20D00; color: white; padding: 10px; border-radius: 5px;",
        strong("✗ Assumptions Not Met"),
        p("Consider the non-parametric alternative:", strong("Mann-Whitney U test."))
      ))
    }
    
    # Case 4: Normality met, but variance unequal (recommend Welch's t-test)
    if (all(!is.na(normality_p)) && all(normality_p > 0.10) && !variance_passed) {
      return(div(
        style = "background-color: #ffc107; color: #222; padding: 10px; border-radius: 5px;",
        strong("! Equal variance assumption not met"),
        p("Data are normally distributed, but variances differ between groups. The independent t-test is not appropriate.",
          "Click below to run ", strong("Welch’s t-test,"), "which accounts for unequal variances."),
        # (Add actionButton here if implementing)
        actionButton("run_welch", "Run Welch’s t-test", class = "btn-warning no-print welch-white")
      ))
    }
    
    # Case 5: Borderline normality (0.05 < p <= 0.10), variance OK
    if (any(!is.na(normality_p) & normality_p > 0.05 & normality_p <= 0.10) && variance_passed) {
      return(div(
        style = "background-color: #ffc107; color: #222; padding: 10px; border-radius: 5px;",
        strong("! Borderline Normality"),
        p("Normality assumption is borderline (Shapiro-Wilk p = 0.05–0.10). Please check the histograms and QQ plots. When uncertain, use the ", strong("Mann-Whitney U test."))
      ))
    }
    
    # Fallback: If assumptions can't be checked due to missing/incomplete data
    div(
      style = "background-color: #B20D00; color: white; padding: 10px; border-radius: 5px;",
      strong("✗ Assumptions Could Not Be Evaluated"),
      p("One or more assumption tests failed due to missing or invalid data.")
    )
  }
  

  ## Dependent t-test
  assumption_summary_dependent <- function(df) {
    group_levels <- levels(df$group)
    if (length(group_levels) != 2) return()
    v1 <- df %>% dplyr::filter(group == group_levels[1]) %>% pull(value)
    v2 <- df %>% dplyr::filter(group == group_levels[2]) %>% pull(value)
    if (length(v1) != length(v2) || length(v1) < 3) {
      return(div(
        style = "background-color: orange; color: white; padding: 10px; border-radius: 5px;",
        strong("Cannot run paired test: Unequal or insufficient values per group. Check your data.")
      ))
    }
    diff <- v1 - v2
    shapiro_diff <- rstatix::shapiro_test(diff)
    shapiro_p <- if ("p.value" %in% names(shapiro_diff)) shapiro_diff$p.value else NA
    min_n <- length(diff)
    
    # Case 1: All assumptions met and n >= 10
    if (!is.na(shapiro_p) && shapiro_p > 0.10 && min_n >= 10) {
      return(div(
        style = "background-color: green; color: white; padding: 10px; border-radius: 5px;",
        strong("✓ Assumptions Passed"),
        p("Parametric paired t-test can be performed with confidence.")
      ))
    }
    # Case 2: Normal, but small sample size (<10)
    if (!is.na(shapiro_p) && shapiro_p > 0.10 && min_n < 10) {
      return(div(
        style = "background-color: #ffc107; color: black; padding: 10px; border-radius: 5px;",
        strong("! Normality assumed but small sample size"),
        p("Normality is met, but at least one group has < 10 observations. Normality tests are unreliable with small samples. Please, check QQ plot and histogram. When uncertain, use the ", strong("Wilcoxon signed-rank test."))
      ))
    }
    # Case 3: Assumptions not met (non-normality)
    if (!is.na(shapiro_p) && shapiro_p <= 0.05) {
      return(div(
        style = "background-color: #B20D00; color: white; padding: 10px; border-radius: 5px;",
        strong("✗ Assumptions Not Met"),
        p("Consider the non-parametric alternative:", strong("Wilcoxon signed-rank test."))
      ))
    }
    # Case 4: Borderline normality (0.05 < p <= 0.10)
    if (!is.na(shapiro_p) && shapiro_p > 0.05 && shapiro_p <= 0.10) {
      return(div(
        style = "background-color: #ffc107; color: #222; padding: 10px; border-radius: 5px;",
        strong("! Borderline Normality"),
        p("Normality assumption is borderline (Shapiro-Wilk p = 0.05–0.10). Please check the histogram and QQ plot. When uncertain, use the ", strong("Wilcoxon signed-rank test."))
      ))
    }
    # Fallback
    div(
      style = "background-color: #B20D00; color: white; padding: 10px; border-radius: 5px;",
      strong("✗ Assumptions Could Not Be Evaluated"),
      p("One or more assumption tests failed due to missing or invalid data.")
    )
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
    
    # Convenience flags
    failed_normality <- any(!is.na(normality_p) & normality_p <= 0.05)
    #borderline_normality <- any(!is.na(normality_p) & normality_p > 0.05 & normality_p <= 0.10)
    borderline_normality <- all(normality_p > 0.05, na.rm = TRUE) && any(normality_p > 0.05 & normality_p <= 0.10, na.rm = TRUE)
    
    failed_variance <- !is.na(variance_p) && variance_p <= 0.05
    
    # Case 1: All assumptions passed
    if (all(!is.na(normality_p)) && all(normality_p > 0.10) && variance_passed) {
      return(div(
        style = "background-color: green; color: white; padding: 10px; border-radius: 5px;",
        strong("✓ Assumptions Passed"),
        p("Parametric test (One-way ANOVA) can be performed with confidence.")
      ))
    }
    
    # Case 2a: Borderline normality (variance OK)
    if (borderline_normality && variance_passed) {
      return(div(
        style = "background-color: #ffc107; color: #222; padding: 10px; border-radius: 5px;",
        strong("! Borderline normality"),
        p("Normality assumption is borderline for one or more groups (Shapiro-Wilk p = 0.05-0.10). Please check the histograms or QQ plots. When uncertain,", strong("Kruskal–Wallis"), "is a robust alternative.")
      ))
    }
    
    # Case 2b: Borderline normality + variance violated
    if (borderline_normality && failed_variance) {
      return(div(
        style = "background-color: #ffc107; color: #222; padding: 10px; border-radius: 5px;",
        strong("! Borderline normality AND equal variance assumption not met"),
        p("Data show borderline normality (Shapiro-Wilk p = 0.05–0.10) and unequal variances. Welch’s ANOVA is not recommended. Use the non-parametric ", strong("Kruskal–Wallis test."))
      ))
    }
    
    # Case 3: Normality OK, variance violated --> show Welch ANOVA button
    if (all(!is.na(normality_p)) && all(normality_p > 0.10) && failed_variance) {
      return(div(
        style = "background-color: #ffc107; color: #222; padding: 10px; border-radius: 5px;",
        strong("! Equal variance assumption not met"),
        p("Data are normally distributed, but variances differ between groups. The standard one-way ANOVA is not appropriate. Click below to run ", strong("Welch’s ANOVA,"), "which accounts for unequal variances."),
        actionButton("run_welch_anova", "Run Welch’s ANOVA", class = "btn-warning no-print welch-white")
      ))
    }
    
    # Case 4: Any group fails normality
    if (failed_normality) {
      return(div(
        style = "background-color: #B20D00; color: white; padding: 10px; border-radius: 5px;",
        strong("✗ Assumptions Not Met"),
        p("Consider a non-parametric alternative:", strong("Kruskal–Wallis test."))
      ))
    }
    
    # Fallback: cannot check assumptions
    div(
      style = "background-color: #B20D00; color: white; padding: 10px; border-radius: 5px;",
      strong("✗ Assumptions Could Not Be Evaluated"),
      p("One or more assumption tests failed due to missing or invalid data.")
    )
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
      showNotification(strong("Levene’s test requires each group to have at least 2 values."), 
                       type = "error", duration = 10)
      return(NULL)
    }
    df %>% rstatix::levene_test(value ~ group)
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
      showNotification(strong("Shapiro–Wilk test needs 3-5000 values per group; groups outside this range cannot be tested."), type = "error", duration = 10)
      return(NULL)
    }
    df %>% dplyr::group_by(group) %>% rstatix::shapiro_test(value)
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
    values1 <- df %>% dplyr::filter(group == group_levels[1]) %>% pull(value)
    values2 <- df %>% dplyr::filter(group == group_levels[2]) %>% pull(value)
    if (length(values1) != length(values2) || length(values1) < 3) return(NULL)
    diff <- values1 - values2
    if (length(diff) < 3 | length(diff) > 5000) {
      showNotification(strong("Need between 3 and 5000 paired values for normality testing (Shapiro-Wilk)."), type = "error")
      return(NULL)
    }
    rstatix::shapiro_test(diff)
  }

  
  # ---- add once near top of server() ----
  SHAPIRO_MSG_ID_ANOVA <- "shapiro_msg_anova"
  shapiro_msg_anova_shown <- reactiveVal(FALSE)
  
  # reset the flag when user (re)runs ANOVA checks
  observeEvent(list(input$test_type, input$check_assumptions), {
    if (identical(input$test_type, "anova")) {
      shapiro_msg_anova_shown(FALSE)
      removeNotification(SHAPIRO_MSG_ID_ANOVA, session = session)
    }
  })
  

  ## ANOVA Shapiro result
  shapiro_result_anova <- function(df) {
    if (all(is.na(df$group))) {
      showNotification(strong("Group column contains only NA. Please select a valid grouping variable."), 
                       type = "error", id = SHAPIRO_MSG_ID_ANOVA)
      return(NULL)
    }
    if (nlevels(df$group) < 2) {
      showNotification(strong("Grouping variable must have at least 2 groups."), type = "error", 
                       id = SHAPIRO_MSG_ID_ANOVA)
      return(NULL)
    }
    group_sizes <- table(df$group)
    if (any(group_sizes < 3) | any(group_sizes > 5000)) {
      showNotification(strong("Shapiro–Wilk test needs 3-5000 values per group; groups outside this range cannot be tested."), type = "error", duration = 10, id = SHAPIRO_MSG_ID_ANOVA)
      return(NULL)
    }
    df %>% dplyr::group_by(group) %>% rstatix::shapiro_test(value)
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
    # Only show if data is available and NOT for nonparametric tests
    if (!is.null(processed_data()) && 
        !(input$test_type %in% c("mannwhitney", "wilcoxon_signed", "kruskal"))) {
      div(
        id = "screenshot_div",
        actionButton("screenshot_btn", "Download Full Report", class = "btn-plot",
                     onclick = "screenshotWithoutDownloadBtns()")
      )
    }
  })
  
  
  # --- Run Statistical Test ---

## Independent t-test
  run_independent_test <- function(df) {
    tryCatch({
      rstatix::t_test(df, value ~ group, paired = FALSE, detailed = TRUE) %>% 
        dplyr::mutate(method = "Independent t-test")
    }, error = function(e) data.frame(p = NA))
  }

## Dependent t-test
  run_dependent_test <- function(df) {
    tryCatch({
      rstatix::t_test(df, value ~ group, paired = TRUE, detailed = TRUE) %>% 
        dplyr::mutate(method = "Paired t-test")
    }, error = function(e) data.frame(p = NA))
  }

# # Mann-Whitney U test
# run_mannwhitney_test <- function(df) {
#   # ngroups <- nlevels(df$group)
#   # if (ngroups == 1) {
#   #   showNotification(
#   #     strong("Only one group detected. Mann–Whitney U test requires exactly two groups."),
#   #     type = "error", duration = 9
#   #   )
#   #   return(data.frame(p = NA))
#   # }
# 
#   # if (ngroups > 2) {
#   #   showNotification(
#   #     strong("More than two groups detected. Check ANOVA assumptions first; if assumptions are violated, AssumpSure will guide you."),
#   #     type = "error", duration = 9,
#   #   )
#   #   return(data.frame(p = NA))
#   # }
#   tryCatch({
#     rstatix::wilcox_test(df, value ~ group, paired = F, detailed = T) %>%
#       dplyr::mutate(method = "Mann-Whitney")
#   }, error = function(e) data.frame(p = NA))
# }
 
   

  ## Mann-Whitney U test
  run_mannwhitney_test <- function(df) {
    ngroups <- nlevels(df$group)
    if (ngroups != 2) return(data.frame(p = NA))
    
    tryCatch({
      rstatix::wilcox_test(df, value ~ group, paired = FALSE, detailed = TRUE) %>%
        dplyr::mutate(method = "Mann–Whitney")
    }, error = function(e) data.frame(p = NA))
  }
  
  
## Wilcoxon signed-rank test
run_wilcoxon_signed_test <- function(df) {
  ngroups <- nlevels(df$group)
  if (ngroups != 2) return(data.frame(p = NA))

  group_sizes <- table(df$group)
  if (length(unique(group_sizes)) != 1) return(data.frame(p = NA))

  tryCatch({
    rstatix::wilcox_test(df, value ~ group, paired = TRUE, detailed = TRUE) %>% 
      dplyr::mutate(method = "Mann-Whitney")
  }, error = function(e) data.frame(p = NA))
}
  

## One-way ANOVA
  run_anova_test <- function(df) {
    tryCatch({
      rstatix::anova_test(df, value ~ group, white.adjust = T)
    }, error = function(e) data.frame(p = NA))
  }

## Kruskal–Wallis Test
  run_kruskal_test <- function(df) {
    tryCatch({
      rstatix::kruskal_test(df, value ~ group)
    }, error = function(e) data.frame(p = NA))
  }
  
  ## Welch's t-test test
  run_welch_test <- function(df) {
    tryCatch({
      rstatix::t_test(df, value ~ group, var.equal = F, paired = F, detailed = T) %>% 
        dplyr::mutate(method = "Welch’s t-test")
    }, error = function(e) data.frame(p = NA))
  }
  

  # Later: add run_wilcoxon_test, run_anova_test, etc.

 # Post hoc test
  output$posthoc_ui <- renderUI({
    df <- processed_data()
    if (is.null(df)) return(NULL)
    if (!(input$test_type %in% c("anova", "kruskal"))) return(NULL)
    if (!assumptions_met()) return(NULL)
    
    # Extra check for Kruskal
    if (input$test_type == "kruskal" && nlevels(df$group) < 3) return(NULL)
    
    pval <- if (input$test_type == "anova") {
      run_anova_test(df)$p[1]
    } else {
      run_kruskal_test(df)$p[1]
    }
    
    if (is.na(pval)) return(NULL)
    
    if (pval < 0.05) {
      if (input$test_type == "anova") {
        tagList(
          br(),
          h4(strong("Post hoc (Tukey HSD & p-value correction)")),
          selectInput("posthoc_method", strong("Choose p-value adjustment method or Tukey HSD:"),
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
      # Show message if not significant
      div(
        style = "background-color: #fff3cd; color: #856404; padding: 10px; border-radius: 
        border:1px solid #ffeeba: 5px; margin-top: 10px;",
        shiny::icon("exclamation-circle", class = "fa-solid", style = "margin-right: 7px;"),
        strong("Post hoc pairwise comparisons are only available if the test was statistically significant.")
      )
    }
  })
  


  # Jump to Assumption Tests when 'Check Assumptions' is clicked
  observeEvent(input$check_assumptions, {
    updateTabsetPanel(session, inputId = "cont_tabs", selected = "Assumption Tests")
  })
  
  # Jump to Test result when click on Welch
  observeEvent(input$run_welch, {
    welch_clicked(TRUE)
    updateTabsetPanel(session, inputId = "cont_tabs", selected = "Test Results")
  })

  # Jump to Test result when click on Welch ANOVA
  observeEvent(input$run_welch_anova, {
    welch_anova_clicked(TRUE)
    updateTabsetPanel(session, inputId = "cont_tabs", selected = "Test Results")
  })
  

  assumptions_checked <- reactiveVal(FALSE)

# Extend this to add the new test
  observeEvent(input$run_test, {

    # Use the correct test type values as in your UI
    parametric_tests <- c("independent_ttest", "dependent_ttest", "anova")
    nonparametric_tests <- c("mannwhitney", "wilcoxon_signed", "kruskal")
    
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

    # Process data for nonparametric tests ONLY when Run Test is clicked
    if (input$test_type %in% nonparametric_tests) {
      df0 <- data()
      if (!is.null(input$timepoint) && input$timepoint != "" && "timepoint" %in% names(df0)) {
        df0 <- dplyr::filter(df0, timepoint == input$timepoint)
      }
      value_is_numeric <- is.numeric(type.convert(df0[[input$value_col]], as.is = TRUE))
      #group_is_numeric <- is.numeric(type.convert(df0[[input$group_col]], as.is = TRUE))
      group_is_numeric <- is.numeric(df0[[input$group_col]])
      
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
        dplyr::mutate(
          value = as.numeric(as.character(value)),
          group = as.factor(group)
        ) %>%
        dplyr::filter(!is.na(value), !is.na(group)) %>%
        droplevels()
      processed_data(df)
    }
    
    # Switch to the test results tab
    updateTabsetPanel(session, inputId = "cont_tabs", selected = "Test Results")

    # Mark test as clicked
    run_test_clicked(Sys.time())
    
    df <- processed_data()

    # Show this message for Mann-Whitney on every button click, not inside renderUI!
    if (input$test_type == "mannwhitney") {
      ngroups <- nlevels(df$group)
      
      if (ngroups == 1) {
        showNotification(
          strong("Only one group detected. Mann–Whitney U test requires exactly two groups."), 
          type = "error", 
          duration = 9
        )
        return()
      }
      
      if (ngroups > 2) {
        showNotification(
          strong("More than two groups detected. Check ANOVA assumptions first; if assumptions are violated, AssumpSure will guide you."), 
          type = "error", 
          duration = 9
        )
        return()
      }
    }
    
    # Show this message for Wilcoxon on every button click, not inside renderUI!
    if (input$test_type == "wilcoxon_signed") {
      ngroups <- nlevels(df$group)
      
      if (ngroups == 1) {
        showNotification(
          strong("Only one group detected. Wilcoxon signed-rank test requires exactly two groups."), 
          type = "error", 
          duration = 9
        )
        return()
      }
      
      if (ngroups > 2) {
        showNotification(
          strong("More than two groups detected. Check ANOVA assumptions first; if assumptions are violated, AssumpSure will guide you."), 
          type = "error", 
          duration = 9
        )
        return()
      }
      
      group_sizes <- table(df$group)
      if (length(unique(group_sizes)) != 1) {
        showNotification(strong("Wilcoxon signed-rank test requires paired samples with equal group sizes. For unpaired or unequal groups, check independent t-test assumptions first; if they are violated, AssumpSure will guide you."), type = "error", duration = 9)
        return()
      }
    }
    
    # >>> NEW BLOCK FOR KRUSKAL HERE <<<
    if (input$test_type == "kruskal") {
      ngroups <- nlevels(df$group)
      
      if (ngroups == 1) {
        showNotification(
          strong("Only one group detected. Kruskal–Wallis requires at least three groups."), 
          type = "error", 
          duration = 9
        )
        return(NULL)
      }
      
      if (ngroups == 2) {
        showNotification(
          strong("Only two groups detected. Check t-test assumptions (paired or independent, as appropriate) first; if they are violated, AssumpSure will guide you to the correct test."), 
          type = "error", 
          duration = 9
        )
        return(NULL)
      }
    }

    # Output rendering
    output$test_result_with_square <- renderUI({
      if (input$test_type == "welch") return(NULL)
      if (!should_show_test_result()) return(NULL)
      df <- processed_data()
      if (is.null(df)) return(NULL)
      
      if (!assumptions_met()) {
        div(
          style = "background-color: #e0e0e0; color: #222; padding: 14px; border-radius: 5px; font-size: 1.1em; margin-top: 10px;",
          strong("This test is not suitable for your data."),
          br(),
          "Assumptions for this test are not met."
        )
      } else {
        tagList(
          uiOutput("actual_test_result"),
          stat_square_func(df),
          
          # Independent t-test: Cohen's d
          if (input$test_type == "independent_ttest") {
            d_res <- tryCatch(
              rstatix::cohens_d(value ~ group, data = df, paired = FALSE),
              error = function(e) NULL
            )
            if (!is.null(d_res)) {
              d_res <- d_res %>% knitr::kable(format = "html", align = "c") %>%
                kableExtra::kable_styling(
                  bootstrap_options = c("hover", "condensed", "bordered"),
                  position = "left", full_width = TRUE) %>%
                kableExtra::scroll_box(width = "100%", height = "100%")
              tagList(
                div(
                  style = "margin-top: 18px;",
                  tags$h5(strong("Effect size (Cohen's d, unpaired)")),
                  div(style = "margin-top: 8px;", HTML(d_res))
                )
              )
            }
          },
          
          # Paired t-test: Cohen's d (paired=TRUE)
          if (input$test_type == "dependent_ttest") {
            d_res <- tryCatch(
              rstatix::cohens_d(value ~ group, data = df, paired = TRUE),
              error = function(e) NULL
            )
            if (!is.null(d_res)) {
              d_res <- d_res %>% knitr::kable(format = "html", align = "c") %>%
                kableExtra::kable_styling(
                  bootstrap_options = c("hover", "condensed", "bordered"),
                  position = "left", full_width = TRUE) %>%
                kableExtra::scroll_box(width = "100%", height = "100%")
              tagList(
                div(
                  style = "margin-top: 18px;",
                  tags$h5(strong("Effect size (Cohen's d, paired)")),
                  div(style = "margin-top: 8px;", HTML(d_res))
                )
              )
            }
          },
          
          # Mann-Whitney U: Wilcoxon effect size (paired=FALSE)
          if (input$test_type == "mannwhitney") {
            w_res <- tryCatch(
              rstatix::wilcox_effsize(value ~ group, data = df, paired = FALSE),
              error = function(e) NULL
            )
            if (!is.null(w_res)) {
              w_res <- w_res %>% knitr::kable(format = "html", align = "c") %>%
                kableExtra::kable_styling(
                  bootstrap_options = c("hover", "condensed", "bordered"),
                  position = "left", full_width = TRUE) %>%
                kableExtra::scroll_box(width = "100%", height = "100%")
              tagList(
                div(
                  style = "margin-top: 18px;",
                  tags$h5(strong("Effect size (Wilcoxon r, unpaired)")),
                  div(style = "margin-top: 8px;", HTML(w_res))
                )
              )
            }
          },
          
          # Wilcoxon Signed-Rank: Wilcoxon effect size (paired=TRUE)
          if (input$test_type == "wilcoxon_signed") {
            w_res <- tryCatch(
              rstatix::wilcox_effsize(value ~ group, data = df, paired = TRUE),
              error = function(e) NULL
            )
            if (!is.null(w_res)) {
              w_res <- w_res %>% knitr::kable(format = "html", align = "c") %>%
                kableExtra::kable_styling(
                  bootstrap_options = c("hover", "condensed", "bordered"),
                  position = "left", full_width = TRUE) %>%
                kableExtra::scroll_box(width = "100%", height = "100%")
              tagList(
                div(
                  style = "margin-top: 18px;",
                  tags$h5(strong("Effect size (Wilcoxon r, paired)")),
                  div(style = "margin-top: 8px;", HTML(w_res))
                )
              )
            }
          },
          
          # ANOVA: Eta squared
          if (input$test_type == "anova") {
            eta_res <- tryCatch(
              aov(value ~ group, data = df) %>%
                rstatix::eta_squared() %>%
                tidyr::as_tibble() %>%
                dplyr::mutate(n = nrow(df)) %>%
                dplyr::rename("effsize" = "value") %>%
                dplyr::mutate(method = "eta2") %>%
                dplyr::mutate(magnitude = dplyr::case_when(
                  effsize < 0.06 ~ "small",
                  effsize >= 0.06 & effsize < 0.14 ~ "medium",
                  effsize >= 0.14 ~ "large"
                )) %>%
                dplyr::mutate(.y. = "value") %>%
                dplyr::select(.y., n, effsize, method, magnitude),
              error = function(e) NULL
            )
            if (!is.null(eta_res)) {
              eta_res <- eta_res %>% knitr::kable(format = "html", align = "c") %>%
                kableExtra::kable_styling(
                  bootstrap_options = c("hover", "condensed", "bordered"),
                  position = "left", full_width = TRUE) %>%
                kableExtra::scroll_box(width = "100%", height = "100%")
              tagList(
                div(
                  style = "margin-top: 18px;",
                  tags$h5(strong("Effect size (Eta squared η²)")),
                  div(style = "margin-top: 8px;", HTML(eta_res))
                )
              )
            }
          },
          
          # Kruskal-Wallis: Eta2[H]
          if (input$test_type == "kruskal") {
            k_res <- tryCatch(
              rstatix::kruskal_effsize(value ~ group, data = df),
              error = function(e) NULL
            )
            if (!is.null(k_res)) {
              k_res <- k_res %>% knitr::kable(format = "html", align = "c") %>%
                kableExtra::kable_styling(
                  bootstrap_options = c("hover", "condensed", "bordered"),
                  position = "left", full_width = TRUE) %>%
                kableExtra::scroll_box(width = "100%", height = "100%")
              tagList(
                div(
                  style = "margin-top: 18px;",
                  tags$h5(strong("Effect size (Kruskal-Wallis eta-squared (η²[H])")),
                  div(style = "margin-top: 8px;", HTML(k_res))
                )
              )
            }
          }
        )
      }
    })
    
    
    output$actual_test_result <- renderUI({
      if (!should_show_test_result()) return(NULL)
      df <- processed_data()
      switch(
        input$test_type,
        "independent_ttest" = {
          res <- run_independent_test(df)
          #res %>% knitr::kable(align = "c", "simple")
          res <- res %>% knitr::kable(format = "html", align = "c")
          res <- res %>% kableExtra::kable_styling(
            bootstrap_options = c("hover", "condensed", "bordered"), 
            position = "left", full_width = T) %>% 
            kableExtra::scroll_box(width = "100%", height = "100%")
          div(style = "margin-top: 15px;",
            HTML(res)
          )
          
        },
        "dependent_ttest"   = {
          res <- run_dependent_test(df)
          #res %>% knitr::kable(align = "c", "simple")
          res <- res %>% knitr::kable(format = "html", align = "c")
          res <- res %>% kableExtra::kable_styling(
            bootstrap_options = c("hover", "condensed", "bordered"), 
            position = "left", full_width = T)
          div(style = "margin-top: 15px;",
              HTML(res)
          )
        },
        "mannwhitney" = {
          res <- run_mannwhitney_test(df)
          #res %>% knitr::kable(align = "c", "simple")
          res <- res %>% knitr::kable(format = "html", align = "c")
          res <- res %>% kableExtra::kable_styling(
            bootstrap_options = c("hover", "condensed", "bordered"), 
            position = "left", full_width = T)
          div(style = "margin-top: 15px;",
              HTML(res)
          )
        },
        "wilcoxon_signed" = {
          res <- run_wilcoxon_signed_test(df)
          #res %>% knitr::kable(align = "c", "simple")
          res <- res %>% knitr::kable(format = "html", align = "c")
          res <- res %>% kableExtra::kable_styling(
            bootstrap_options = c("hover", "condensed", "bordered"), 
            position = "left", full_width = T) 
          div(style = "margin-top: 15px;",
              HTML(res)
          )
        },
        "anova" = {
          res <- run_anova_test(df)
          #res %>% knitr::kable(align = "c", "simple")
          res <- res %>% knitr::kable(format = "html", align = "c")
          res <- res %>% kableExtra::kable_styling(
            bootstrap_options = c("hover", "condensed", "bordered"), 
            position = "left", full_width = T)%>% 
            kableExtra::scroll_box(width = "100%", height = "100%")
          div(style = "margin-top: 15px;",
              HTML(res)
          )
        },
        "kruskal" = {
          res <- run_kruskal_test(df)
          #res %>% knitr::kable(align = "c", "simple")
          res <- res %>% knitr::kable(format = "html", align = "c")
          res <- res %>% kableExtra::kable_styling(
            bootstrap_options = c("hover", "condensed", "bordered"), 
            position = "left", full_width = T)%>% 
            kableExtra::scroll_box(width = "100%", height = "100%")
          div(style = "margin-top: 15px;",
              HTML(res)
          )
        },
        "chisq" = {
          res <- run_chisq_test(df)
          #res %>% knitr::kable(align = "c", "simple")
          res <- res %>% knitr::kable(format = "html", align = "c")
          res <- res %>% kableExtra::kable_styling(
            bootstrap_options = c("hover", "condensed", "bordered"), 
            position = "left", full_width = T)%>% 
            kableExtra::scroll_box(width = "100%", height = "100%")
          div(style = "margin-top: 15px;",
              HTML(res)
          )
        },
        "fisher" = {
          res <- run_fisher_test(df)
          #res %>% knitr::kable(align = "c", "simple")
          res <- res %>% knitr::kable(format = "html", align = "c")
          res <- res %>% kableExtra::kable_styling(
            bootstrap_options = c("hover", "condensed", "bordered"), 
            position = "left", full_width = T)%>% 
            kableExtra::scroll_box(width = "100%", height = "100%")
          div(style = "margin-top: 15px;",
              HTML(res)
          )
        },
        ## add the rest
        NULL
      )
    })
    
  })
  
  # Show Welch result UI when clicked:
  output$welch_result <- renderUI({
    req(welch_clicked())
    df <- processed_data()
    if (is.null(df)) return(NULL)
    res <- run_welch_test(df)
    res_tbl <- res %>% 
      knitr::kable(format = "html", align = "c") %>%
      kableExtra::kable_styling(
        bootstrap_options = c("hover", "condensed", "bordered"), 
        position = "left", full_width = TRUE
      ) %>%
      kableExtra::scroll_box(width = "100%", height = "100%")
    
    # Colored square (significance)
    square <- stat_square_welch(df)
    
    # Effect size (Cohen's d, Welch version)
    effsize <- df %>% rstatix::cohens_d(value ~ group, var.equal = FALSE)
    effsize_tbl <- effsize %>%
      knitr::kable(format = "html", align = "c") %>%
      kableExtra::kable_styling(
        bootstrap_options = c("hover", "condensed", "bordered"),
        position = "left", full_width = TRUE
      ) %>%
      kableExtra::scroll_box(width = "100%", height = "100%")
    
    div(
      style = "margin-top: 15px;",
      HTML(res_tbl),
      square,
      div(style = "margin-top: 18px;"),   # Space before Cohen's d
      tags$h5(strong("Effect size (Cohen's d, unpaired)")),
      HTML(effsize_tbl)
    )
  })
  
  
  # Welch's ANOVA
  output$welch_anova_result <- renderUI({
    req(welch_anova_clicked())
    df <- processed_data()
    if (is.null(df)) return(NULL)
    
    # 1. Run Welch ANOVA
    res <- tryCatch({
      rstatix::welch_anova_test(df, value ~ group)
    }, error = function(e) data.frame(p = NA))
    
    res_tbl <- res %>%
      knitr::kable(format = "html", align = "c") %>%
      kableExtra::kable_styling(
        bootstrap_options = c("hover", "condensed", "bordered"),
        position = "left", full_width = TRUE
      ) %>%
      kableExtra::scroll_box(width = "100%", height = "100%")
    
    # 2. Significance Square
    pval <- if ("p" %in% names(res)) res$p[1] else NA
    square <- div(
      style = paste0(
        "background-color: ", if (!is.na(pval) && pval < 0.05) "green" else "#B20D00",
        "; color: white; padding: 10px; border-radius: 5px; margin-top: 10px;"
      ),
      strong(if (!is.na(pval) && pval < 0.05) "Statistically Significant Difference" else "No Statistically Significant Difference")
    )
    
    # 3. Effect size: Omega squared (ω²) using effectsize package
    effsize_tbl <- NULL
    if (requireNamespace("effectsize", quietly = TRUE)) {
      welch_mod <- tryCatch(oneway.test(value ~ group, data = df, var.equal = FALSE), error = function(e) NULL)
      effsize <- tryCatch(effectsize::omega_squared(welch_mod), error = function(e) NULL)
      if (!is.null(effsize)) {
        effsize_df <- as.data.frame(effsize)
        effsize_df$method <- "omega2"
        effsize_df$magnitude <- dplyr::case_when(
          effsize_df$Omega2 < 0.01 ~ "negligible",
          effsize_df$Omega2 < 0.06 ~ "small",
          effsize_df$Omega2 < 0.14 ~ "medium",
          TRUE ~ "large"
        )
        effsize_tbl <- effsize_df %>%
          knitr::kable(format = "html", align = "c") %>%
          kableExtra::kable_styling(
            bootstrap_options = c("hover", "condensed", "bordered"),
            position = "left", full_width = TRUE
          ) %>%
          kableExtra::scroll_box(width = "100%", height = "100%")
      }
    }
    

    # 4. Post hoc: Button if significant, else warning message
    posthoc_ui <- if (!is.na(pval) && pval < 0.05) {
      actionButton("run_games_howell", "Run Post hoc Test", class = "btn-plot",
                   style = "margin-top: 15px;")
    } else {
      div(
        style = "background-color: #fff3cd; color: #856404; padding: 10px; border-radius: 5px; border:1px solid #ffeeba; margin-top: 10px;",
        shiny::icon("exclamation-circle", class = "fa-solid", style = "margin-right: 7px;"),
        strong("Post hoc pairwise comparisons are only available if the test was statistically significant.")
      )
    }
    
    
    tagList(
      div(style = "margin-top: 15px;", HTML(res_tbl)),
      square,
      if (!is.null(effsize_tbl)) {
        tagList(
          div(style = "margin-top: 18px;"),
          tags$h5(strong("Effect size (Omega squared, ω²)")),
          div(style = "margin-top: 8px;", HTML(effsize_tbl))
        )
      },
      posthoc_ui,                       # Post hoc button or warning message
      uiOutput("posthoc_result_ui"),    # Then post hoc results
      
      tagList(actionButton("plot_boxplot_welch_anova", "Plot Boxplot", class = "btn-plot", style = "margin-top: 12px;")),
              # Tooltip icon placed next to the button
              tags$span(
                icon("info-circle", class = "fa-solid"),
                `data-bs-toggle` = "tooltip",
                `data-bs-placement` = "right",
                title = "****: p < 0.0001\n***: p < 0.001\n**: p < 0.01\n*: p < 0.05\nns: Not significant",
                style = "color: #010001; cursor: pointer; margin-left: 6px; position: relative; top: 7px;"
              ),
      plotOutput("boxplot_welch_anova", height = "350px"),
      downloadButton("download_boxplot_welch_anova", "Download Boxplot", class = "no-print", style = "margin-top: 10px;")
    )
    
    
  })
  
  # Observe Games-Howell post hoc button
  observeEvent(input$run_games_howell, {
    df <- processed_data()
    # Games-Howell requires >= 3 groups
    if (is.null(df) || nlevels(df$group) < 3) {
      showNotification(strong("Games-Howell test requires at least 3 groups."), type = "error")
      return(NULL)
    }
    # 1. Games-Howell
    posthoc <- tryCatch({
      rstatix::games_howell_test(df, value ~ group, detailed = TRUE)
    }, error = function(e) data.frame(error = e$message))
    
    output$posthoc_result_ui <- renderUI({
      if (is.null(posthoc)) return(NULL)
      
      # Games-Howell table
      tbl_post <- posthoc %>%
        knitr::kable(format = "html", align = "c") %>%
        kableExtra::kable_styling(bootstrap_options = c("hover", "condensed", "bordered"),
                                  position = "left") %>%
        kableExtra::scroll_box(width = "100%", height = "100%")
      
      # Compute pairwise Cohen's d
      effsize_tbl <- NULL
      pairs <- unique(posthoc[, c("group1", "group2")])
      
      if (nrow(pairs) > 0 && all(c("group1", "group2") %in% names(pairs))) {
        effsize_list <- lapply(1:nrow(pairs), function(i) {
          g1 <- as.character(pairs$group1[i])
          g2 <- as.character(pairs$group2[i])
          dat <- subset(processed_data(), group %in% c(g1, g2))
          dat$group <- droplevels(dat$group)
          tryCatch({
            # Always Cohen's d for Welch
            rstatix::cohens_d(value ~ group, data = dat, paired = FALSE)
          }, error = function(e) NULL)
        })
        effsize_tbl <- dplyr::bind_rows(effsize_list) %>%
          knitr::kable(format = "html", align = "c") %>%
          kableExtra::kable_styling(bootstrap_options = c("hover", "condensed", "bordered"), 
                                    position = "left", full_width = TRUE) %>%
          kableExtra::scroll_box(width = "100%", height = "100%")
      }
      
      tagList(
        tags$h5(style = "margin-top: 10px;", strong("Games-Howell Post hoc Results")),
        HTML(tbl_post),
        if (!is.null(effsize_tbl)) {
          tagList(
            div(style = "margin-top: 18px;"),
            tags$h5(strong("Effect Size (Cohen’s d) for Each Pairwise Comparison")),
            div(style = "margin-top: 8px;", HTML(effsize_tbl))
          )
        }
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

  should_show_test_result <- reactive({
    df <- processed_data()
    if (is.null(df)) return(FALSE)
    res <- switch(
      input$test_type,
      "wilcoxon_signed" = run_wilcoxon_signed_test(df),
      "mannwhitney"     = run_mannwhitney_test(df),
      "independent_ttest" = run_independent_test(df),
      "dependent_ttest"   = run_dependent_test(df),
      "anova" = run_anova_test(df),
      "kruskal" = run_kruskal_test(df),
      NULL
    )
    if (is.null(res)) return(FALSE)
    if ("p" %in% names(res) && is.na(res$p[1])) return(FALSE)
    TRUE
  })
  

  # --- Put these right after the above block ---
  observeEvent(input$file,     { run_test_clicked(FALSE) })
  observeEvent(input$test_type, {
    # Reset flag for whether Run Test has been clicked
    run_test_clicked(FALSE)
    
    # Reset any processed data (so no stale data is reused)
    processed_data(NULL)
    
    # Reset Welch test flag if you have one
    welch_clicked(FALSE)
    
    # Clear any error messages or status reactives (if you use them)
    # error_status(NULL)
    
    # Clear the main test result output UI
    output$test_result_with_square <- renderUI({ NULL })
    
    # Clear boxplot or other plot outputs
    output$your_boxplot_output <- renderPlot({ NULL })  # Use actual output IDs
    
    # If you have other download button logic, reset those as well
    # download_enabled(FALSE)
  })

  # --- Statistical Significance Square ---

## Independent t-test
  stat_square_independent <- function(df) {
    pval <- run_independent_test(df)$p[1]
    if (is.na(pval)) return(NULL)
    div(style = paste0("background-color: ", if (pval < 0.05) "green" else "#B20D00", "; color: white; padding: 10px; border-radius: 5px; margin-top: 10px;"),
        strong(if (pval < 0.05) "Statistically Significant Difference" else "No Statistically Significant Difference"))
  }
  
  ## Welch's test
  stat_square_welch <- function(df) {
    pval <- run_welch_test(df)$p[1]
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

# Statistic square for Welch's test
output$welch_square <- renderUI({
  req(input$run_welch)  # Triggers when Welch is run
  df <- processed_data()
  if (is.null(df)) return(NULL)
  stat_square_welch(df)
})


output$welch_boxplot_ui <- renderUI({
  req(welch_clicked())
  tagList(
    actionButton("plot_boxplot_welch", "Plot Boxplot", class = "btn-plot", style = "margin-top: 10px;"),
    # Tooltip icon placed next to the button
    tags$span(
      icon("info-circle", class = "fa-solid"),
      `data-bs-toggle` = "tooltip",
      `data-bs-placement` = "right",
      title = "****: p < 0.0001\n***: p < 0.001\n**: p < 0.01\n*: p < 0.05\nns: Not significant",
      style = "color: #010001; cursor: pointer; margin-left: 6px; position: relative; top: 5px;"
    ),
    plotOutput("boxplot_welch", height = "350px"),
    downloadButton("download_boxplot_welch", "Download Boxplot", class = "no-print", style = "margin-top: 10px;")
  )
})


output$boxplot_ui <- renderUI({
  # Only show boxplot when appropriate
  req(run_test_clicked())
  df <- processed_data()
  test <- input$test_type
  
  # Don't show for missing data or failed assumptions
  if (is.null(df) || !assumptions_met()) return(NULL)
  
  # Mann-Whitney: must have exactly 2 groups
  if (test == "mannwhitney" && nlevels(df$group) != 2) return(NULL)
  
  # Wilcoxon signed-rank: must have exactly 2 groups AND equal sizes (paired data)
  if (test == "wilcoxon_signed") {
    if (nlevels(df$group) != 2) return(NULL)
    group_sizes <- table(df$group)
    if (length(unique(group_sizes)) != 1) return(NULL)
  }
  
  # For Kruskal: Only show if >= 3 groups
  if (test == "kruskal" && nlevels(df$group) < 3) return(NULL)
  
  tagList(
    # Action button
    actionButton(
      "plot_boxplot",
      "Plot Boxplot",
      class = "btn-plot"
    ),
    
    # Tooltip icon placed next to the button
    tags$span(
      icon("info-circle", class = "fa-solid"),
      `data-bs-toggle` = "tooltip",
      `data-bs-placement` = "right",
      title = "****: p < 0.0001\n***: p < 0.001\n**: p < 0.01\n*: p < 0.05\nns: Not significant",
      style = "color: #010001; cursor: pointer; margin-left: 6px;"
    ),
    plotOutput("boxplot"),
    downloadButton("download_boxplot", "Download Boxplot", class = "no-print")
  )
})




  # --- Boxplot (independent) ---
  plot_independent_boxplot <- function(df) {
    
    # Always coerce to factor and drop unused levels
    df$group <- factor(df$group)
    levs <- levels(df$group)
    # Only allow exactly 2 groups for this test
    if(length(levs) != 2) return(ggplot2::ggplot() + labs(title = "Requires exactly 2 groups"))
    
    # Explicitly set the comparison
    comparison <- list(c(levs[1], levs[2]))
    
    ggplot2::ggplot(df, aes(x = group, y = value, fill = group)) +
      geom_boxplot(alpha = 0.7, width = 0.3, outlier.colour = NA) +
      geom_jitter(width = 0.1, alpha = 0.5, shape = 21, size = 1.3) +
      theme_test() +
      scale_fill_brewer(palette = "Set2") +
      scale_color_brewer(palette = "Set2") +
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
      geom_flat_violin(position = position_nudge(x = 0.2, y = 0), alpha = 0.8, adjust = 0.9, width = 0.5) +
      ggpubr::stat_compare_means(comparisons = comparison, method = "t.test", paired = FALSE, 
                                 label = "p.signif", label.size = 3.5, vjust = 0.2, tip.length = 0.02)
    
  }


  # --- Boxplot (dependant) ---
  plot_dependent_boxplot <- function(df) {
    
    # Always coerce to factor and drop unused levels
    df$group <- factor(df$group)
    levs <- levels(df$group)
    # Only allow exactly 2 groups for this test
    if(length(levs) != 2) return(ggplot2::ggplot() + labs(title = "Requires exactly 2 groups"))
   
    # Explicitly set the comparison
    comparison <- list(c(levs[1], levs[2]))
    
    
    ggplot2::ggplot(df, aes(x = group, y = value, fill = group)) +
      geom_boxplot(alpha = 0.7, width = 0.3, outlier.colour = NA) +
      geom_jitter(width = 0.1, alpha = 0.5, shape = 21, size = 1.3) +
      theme_test() +
      scale_fill_brewer(palette = "Set2") +
      scale_color_brewer(palette = "Set2") +
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
      geom_flat_violin(position = position_nudge(x = 0.2, y = 0), alpha = 0.8, adjust = 0.9, width = 0.5) + 
      ggpubr::stat_compare_means(comparisons = comparison, method = "t.test", paired = TRUE, 
                                 label = "p.signif", label.size = 3.5, vjust = 0.2, tip.length = 0.02)
  }

  # --- Boxplot (Mann-Whitney) ---
  plot_mannwhitney_boxplot <- function(df) {
    
    # Always coerce to factor and drop unused levels
    df$group <- factor(df$group)
    levs <- levels(df$group)
    
    # Only allow exactly 2 groups for this test
    if(length(levs) != 2) return(ggplot2::ggplot() + labs(title = "Requires exactly 2 groups"))
    
    # Explicitly set the comparison
    comparison <- list(c(levs[1], levs[2]))
    
    ggplot2::ggplot(df, aes(x = group, y = value, fill = group)) +
      geom_boxplot(alpha = 0.7, width = 0.3, outlier.colour = NA) +
      geom_jitter(width = 0.1, alpha = 0.5, shape = 21, size = 1.3) +
      theme_test() +
      scale_fill_brewer(palette = "Set2") +
      scale_color_brewer(palette = "Set2") +
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
      geom_flat_violin(position = position_nudge(x = 0.2, y = 0), alpha = 0.8, adjust = 0.9, width = 0.5) +
      ggpubr::stat_compare_means(comparisons = comparison, method = "wilcox.test", paired = FALSE, 
                                 label = "p.signif", label.size = 3.5, vjust = 0.2, tip.length = 0.02)
  }

# --- Boxplot (Wilcoxon signed-rank test) ---
  plot_wilcoxon_boxplot <- function(df) {
    
    # Always coerce to factor and drop unused levels
    df$group <- factor(df$group)
    levs <- levels(df$group)
    # Only allow exactly 2 groups for this test
    if(length(levs) != 2) return(ggplot2::ggplot() + labs(title = "Requires exactly 2 groups"))
    
    # Explicitly set the comparison
    comparison <- list(c(levs[1], levs[2]))
    
    ggplot2::ggplot(df, aes(x = group, y = value, fill = group)) +
      geom_boxplot(alpha = 0.7, width = 0.3, outlier.colour = NA) +
      geom_jitter(width = 0.1, alpha = 0.5, shape = 21, size = 1.3) +
      theme_test() +
      scale_fill_brewer(palette = "Set2") +
      scale_color_brewer(palette = "Set2") +
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
      geom_flat_violin(position = position_nudge(x = 0.2, y = 0), alpha = 0.8, adjust = 0.9, width = 0.5) + 
      ggpubr::stat_compare_means(comparisons = comparison, method = "wilcox.test", paired = TRUE, 
                                 label = "p.signif", label.size = 3.5, vjust = 0.2, tip.length = 0.02)
  }

# --- Boxplot (Anova) ---
  plot_anova_boxplot <- function(df) {
    
    # Ensure group is a factor
    df$group <- factor(df$group)
    levs <- levels(df$group)
    # Create all pairwise comparisons
    #comparisons <- combn(levs, 2, simplify = FALSE)
    
    # Perform one-way ANOVA
    anova_res <- rstatix::anova_test(data = df, value ~ group)
    
    # Tukey's HSD post-hoc test
    tukey_res <- rstatix::tukey_hsd(df, value ~ group) %>%
      rstatix::add_xy_position(x = "group", step.increase = 0.1)  # avoids bracket overlap
    
    
    comparison <- combn(unique(df$group), 2, simplify = FALSE)
    p <- ggplot2::ggplot(df, aes(x = group, y = value, fill = group)) +
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
      geom_flat_violin(position = position_nudge(x = 0.2, y = 0), alpha = 0.8, adjust = 0.9, width = 0.5) + 
      ggpubr::stat_pvalue_manual(
        tukey_res,
        label = "p.adj.signif",   # show stars instead of p-values
        size = 4,             # bigger stars
        tip.length = 0.01
      )
      #ggpubr::stat_compare_means(comparisons = comparisons, method = "wilcox.test", paired = FALSE, 
      #                           label = "p.signif", size = 5.5, vjust = 0.5, 
      #                           p.adjust.method = "BH")
    # Only apply Set2 if ≤ 8 groups
    if(length(levs) <= 8) {
      p <- p + scale_fill_brewer(palette = "Set2") + scale_color_brewer(palette = "Set2")
    }
    p
  }

  # --- Boxplot (Kruskal) ---
  plot_kruskal_boxplot <- function(df) {
    
    # Ensure group is a factor
    df$group <- factor(df$group)
    levs <- levels(df$group)
    # Create all pairwise comparisons
   # comparisons <- combn(levs, 2, simplify = FALSE)
    
    # Perform Kruskal-Wallis test
    kruskal_res <- rstatix::kruskal_test(df, value ~ group)
    
    # Dunn's post-hoc test with p-value adjustment + bracket positions
    dunn_res <- rstatix::dunn_test(df, value ~ group, p.adjust.method = "BH") %>%
      rstatix::add_xy_position(x = "group", step.increase = 0.1)
    
    #comparison <- combn(unique(df$group), 2, simplify = FALSE)
    p <- ggplot2::ggplot(df, aes(x = group, y = value, fill = group)) +
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
      geom_flat_violin(position = position_nudge(x = 0.2, y = 0), alpha = 0.8, adjust = 0.9, width = 0.5) + 
      ggpubr::stat_pvalue_manual(
        dunn_res,
        label = "p.adj.signif",
        tip.length = 0.01,
        hide.ns = FALSE,
        size = 4
      )
      #ggpubr::stat_compare_means(comparisons = comparisons, method = "wilcox.test", paired = FALSE, 
      #                           label = "p.signif", size = 5.5, vjust = 0.5, 
      #                           p.adjust.method = "BH")
    
    # Only apply Set2 if ≤ 8 groups
    if(length(levs) <= 8) {
      p <- p + scale_fill_brewer(palette = "Set2") + scale_color_brewer(palette = "Set2")
    }
    p
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
      ggsave(file, plot = p, width = 5, height = 4, dpi = 600, bg = "white")
    }
  )
  
  observeEvent(input$plot_boxplot_welch, {
    output$boxplot_welch <- renderPlot({
      df <- processed_data()
      if (is.null(df)) return(NULL)
      plot_independent_boxplot(df) # I used in-dependent plot
    })
  })
  
  output$download_boxplot_welch <- downloadHandler(
    filename = function() {
      paste0("welch_boxplot_", Sys.Date(), ".png")
    },
    content = function(file) {
      df <- processed_data()
      if (is.null(df)) return(NULL)
      p <- plot_independent_boxplot(df) # I used in-dependent plot
      ggsave(file, plot = p, width = 5, height = 4, dpi = 600, bg = "white")
    }
  )
  
  # Boxplot Welch anova
  observeEvent(input$plot_boxplot_welch_anova, {
    output$boxplot_welch_anova <- renderPlot({
      df <- processed_data()
      if (is.null(df)) return(NULL)
      plot_anova_boxplot(df)  # Reuse your ANOVA boxplot function
    })
  })
  
  output$download_boxplot_welch_anova <- downloadHandler(
    filename = function() {
      paste0("welch_anova_boxplot_", Sys.Date(), ".png")
    },
    content = function(file) {
      df <- processed_data()
      if (is.null(df)) return(NULL)
      p <- plot_anova_boxplot(df)
      ggsave(file, plot = p, width = 6, height = 4, dpi = 600, bg = "white")
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

  fisher_computational_error <- reactiveVal(FALSE)
  invalid_fisher_square <- reactiveVal(FALSE)
  
  ## Read the data and update timepoint dropdown
  fisher_data <- reactive({
    req(input$file_fisher)
    df <- readr::read_csv(input$file_fisher$datapath, show_col_types = F) %>%
      dplyr::select(
        -dplyr::contains("infant_id", ignore.case = TRUE),
        -dplyr::contains("infantid", ignore.case = TRUE),
        -dplyr::contains("sample_id", ignore.case = TRUE),
        -dplyr::contains("sampleid", ignore.case = TRUE),
        -dplyr::contains("sample", ignore.case = TRUE),
        -dplyr::contains("accession", ignore.case = TRUE),
        -dplyr::contains("name", ignore.case = TRUE)
      )
    for (nm in names(df)) {
      if (nm != "timepoint") {
        col <- df[[nm]]
        if (is.character(col) && length(unique(col)) <= 15) {
          df[[nm]] <- factor(col)
        } else if (is.logical(col)) {
          df[[nm]] <- factor(col)
        } else if (is.numeric(col) && all(col == floor(col), na.rm = TRUE) && length(unique(col)) <= 15) {
          df[[nm]] <- as.character(col)   # numeric-coded categorical → character
        }
      }
    }
    df
  })

  run_fisher_clicked <- reactiveVal(FALSE)

  run_fisher_clicked <- reactiveVal(FALSE)
  observeEvent(list(input$file_fisher, input$cat1, input$cat2, input$test_type_fisher), {
    run_fisher_clicked(FALSE)
  })
  
  # UI for selecting first categorical variable
  output$cat1_ui <- renderUI({
    df <- fisher_data()
    if (is.null(df)) return(NULL) ## only show after upload
    
    cat_vars <- names(df)[sapply(df, function(col)
      is.character(col) || is.factor(col) || is.logical(col))]
    
    selectInput("cat1", 
                tagList(
                  "Select first categorical variable:",
                  tags$span(
                    icon("info-circle", class = "fa-solid"),
                    `data-bs-toggle` = "tooltip",
                    `data-bs-placement` = "right",
                    title = "Note: Categorical variables are limited to 15 unique levels to improve validity and interpretability of Fisher’s exact and Chi-square tests, as larger tables often violate expected-count assumptions and yield less reliable results."
                  )),
                choices = c("Select variable" = "", cat_vars),
                selected = "")
  })
  
  # UI for selecting second categorical variable, excluding the first
  output$cat2_ui <- renderUI({
    df <- fisher_data()
    if (is.null(df)) return(NULL) ## only show after upload
    
    cat_vars <- names(df)[sapply(df, function(col)
      is.character(col) || is.factor(col) || is.logical(col))]
    
    selectInput("cat2", 
                tagList(
                "Select second categorical variable:",
                tags$span(
                  icon("info-circle", class = "fa-solid"),
                  `data-bs-toggle` = "tooltip",
                  `data-bs-placement` = "right",
                  title = "Note: Categorical variables are limited to 15 unique levels to improve validity and interpretability of Fisher’s exact and Chi-square tests, as larger tables often violate expected-count assumptions and yield less reliable results."
                )),
                choices = c("Select variable" = "", cat_vars),
                selected = "")
  })
  
  
  ## ---- Fisher: re-init tooltips after renderUI ----
  session$onFlushed(function() {
    session$sendCustomMessage("reinit-tooltips", list())
  }, once = FALSE)
  
  

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
  
  # Dynamic UI for test type
  output$test_type_fisher_ui <- renderUI({
    selectInput("test_type_fisher", "Choose test:",
                choices = c("Choose Test" = "",
                            "Chi-square test" = "chisq",
                            "Fisher’s exact test" = "fisher"),
                selected = "")
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
    updateSelectInput(session, "cat1", 
                      choices = c("Select variable" = "", cat_vars), 
                      selected = "")
    updateSelectInput(session, "cat2", 
                      choices = c("Select variable" = "", cat_vars),
                      selected = "")
  })


  
  reset_outputs <- function() {
    msg_test <- div(
      style = "
      background-color: #f5f5f5; color: #555; font-weight: bold; font-size: 1em;
      border-radius: 8px; padding: 10px; margin: 5px 0;
      text-align: left;",
      "Awaiting test results."
    )
    msg_posthoc <- div(
      style = "
      background-color: #f5f5f5; color: #555; font-weight: bold; font-size: 1em;
      border-radius: 8px; padding: 10px; margin: 5px 0;
      text-align: left;",
      "Awaiting post-hoc pairwise comparison results."
    )
    output$fisher_chisq_result <- renderUI({ msg_test })
    output$posthoc_result_fisher <- renderUI({ msg_posthoc })
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


    output$fisher_chisq_result <- renderUI({
      fisher_computational_error(FALSE)
      df <- fisher_data()
      # Filter by timepoint if selected
      if (!is.null(input$fisher_timepoint) && input$fisher_timepoint != "" && "timepoint" %in% names(df)) {
        df <- dplyr::filter(df, timepoint == input$fisher_timepoint)
      }
      
      # No data after filtering
      if (nrow(df) == 0) {
        return(invisible(NULL))
      }
      
      tab <- df %>%
        dplyr::select(.data[[input$cat1]], .data[[input$cat2]]) %>%
        tidyr::drop_na() %>%
        table()
      
      # Special check for degenerate case
      if (any(dim(tab) < 2)) {
        invalid_fisher_square(TRUE)
        shiny::showModal(modalDialog(
          title = div(icon("exclamation-triangle", lib = "font-awesome"), "Invalid data"),
          div(
            style = "background-color:#f8d7da; color:#721c24; padding:14px; border:1px solid #f5c6cb; border-radius:5px; margin-bottom:12px;",
            icon("exclamation-circle", lib = "font-awesome"),
            strong(" Error: "),
            "Chi-square and Fisher's Exact Tests requires at least two groups for each variable. Your data contains only one group in one or both variables. Please provide a dataset with at least two distinct groups for each variable to use Fisher's Exact Test or Chi-square."
          ),
          easyClose = TRUE,
          footer = NULL
        ))
        # Also clear other outputs
        #output$fisher_chisq_square <- renderUI({ NULL })
        output$posthoc_result_fisher <- renderUI({ invisible(NULL) })
        return(invisible(NULL))
      } else {
        invalid_fisher_square(FALSE)
      }
      
      
      # Now do the test logic
      warn_msg <- NULL
      table_output <- NULL
      
      tryCatch({
        if (input$test_type_fisher == "chisq") {
          test <- chisq.test(tab)
          exp_counts <- test$expected
          
          # Store warning if expected count < 5
          # if (any(exp_counts < 5)) {
          #   warn_msg <- div(
          #     style = "background-color:#fff3cd; color:#856404; padding:14px; border:1px solid #ffeeba; border-radius:5px; margin-bottom:12px;",
          #     icon("exclamation-triangle", lib = "font-awesome"),
          #     strong(" Warning: "),
          #     "Some expected cell counts are less than 5. Consider using Fisher's exact test instead of Chi-square."
          #   )
          # }
          
          table_output <- rstatix::chisq_test(tab) %>%
            knitr::kable(align = "c", format = "html") %>%
            kableExtra::kable_styling(
              bootstrap_options = c("hover", "condensed", "bordered"),
              position = "center", full_width = TRUE)
          
        } else {
          result <- tryCatch({
            rstatix::fisher_test(tab, detailed = TRUE)
          }, error = function(e) {
            # THIS IS THE CRITICAL PART FOR FEXACT error 6
            if (grepl("FEXACT error 6", e$message, fixed = TRUE)) {
              fisher_computational_error(TRUE)
              return(
                div(
                  style = "background-color:#f8d7da; color:#721c24; padding:14px; border:1px solid #f5c6cb; border-radius:5px; margin-bottom:12px; margin-top:10px;",
                  icon("exclamation-triangle", lib = "font-awesome"),
                  strong(" Fisher's Exact Test failed: "),
                  "The table is too large or complex for Fisher's Exact Test. Please use the", strong("Chi-squared test"), "instead."
                )
              )
            } else {
              return(invisible(NULL))
            }
          })
          if (inherits(result, "shiny.tag")) return(result)
          table_output <- result %>%
            knitr::kable(align = "c", format = "html") %>%
            kableExtra::kable_styling(
              bootstrap_options = c("hover", "condensed", "bordered"),
              position = "center", full_width = TRUE)
        }
        
        
        # Combine warning (if any) with table output
        tagList(
          warn_msg,
          div(style = "margin-top:24px;", HTML(table_output))
        )
      }, error = function(e) {
        # Also suppress any red error in UI here
        return(invisible(NULL))
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
      if (fisher_computational_error()) return(invisible(NULL))
      if (!run_fisher_clicked()) return(NULL)
      tab <- df %>%
        dplyr::select(.data[[input$cat1]], .data[[input$cat2]]) %>%
        table()
      if (any(dim(tab) < 2)) return(invisible(NULL))
      

      count1 <- nlevels(droplevels(df[[input$cat1]]))
      count2 <- nlevels(droplevels(df[[input$cat2]]))
      more_than_2 <- (count1 > 2 | count2 > 2)
      
      pval <- NA_real_
      if (input$test_type_fisher == "chisq") {
        pval <- tryCatch(rstatix::chisq_test(tab)$p[1], error = function(e) NA_real_)
      } else {
        pval <- tryCatch(rstatix::fisher_test(tab)$p[1], error = function(e) NA_real_)
      }

      if (!more_than_2) {
        return(invisible(NULL)) # Show nothing
      } else if (is.na(pval) || pval >= 0.05) {
        return(invisible(NULL)) # Also show nothing here, since UI already tells user why
      } else if (input$posthoc_method_fisher == "" || is.null(input$posthoc_method_fisher)) {
        return(
          div(style = "background-color: #eaf4fb; color: #215273; font-weight: bold;
        font-size: 1 em; border: 1px solid #b5d6ea; border-radius: 7px;
        padding: 7px 8px; margin: -10px 0 6px 0; text-align: left;",
            " Please select a p-value adjustment method to view post hoc pairwise comparisons.")
        )
      } else {
        # test is significant, more than 2 groups, and method is selected
        p_adj_method <- input$posthoc_method_fisher
        if (input$test_type_fisher == "chisq") {
          res <- tryCatch(
            rstatix::pairwise_prop_test(tab, p.adjust.method = p_adj_method) %>% 
              dplyr::mutate(method = "Pairwise Proportion Test"),
            error = function(e) NULL
          )
        } else {
          res <- tryCatch(
            rstatix::pairwise_fisher_test(tab, p.adjust.method = p_adj_method) %>% 
              dplyr::mutate(method = "Pairwise Fisher’s Exact Test"),
            error = function(e) NULL
          )
        }
        if (!is.null(res) && nrow(res) > 0) {
          tbl_pos_fish <- knitr::kable(res, align = "c", format = "html") %>% 
            kableExtra::kable_styling(
              bootstrap_options = c("hover", "condensed", "bordered"),
              position = "center", full_width = TRUE)
          HTML(tbl_pos_fish)
        } else {
          cat("Could not compute pairwise post hoc test. Check your data for missing values or errors.")
        }
      }
      
    })

  
    output$posthoc_method_ui <- renderUI({
      if (fisher_computational_error()) return(invisible(NULL))
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
          style = "background-color:#fff3cd; color:#856404; padding:10px; border:1px solid #ffeeba; border-radius:5px; margin-bottom:12px; margin-top:-15px;",
          strong("Post hoc pairwise comparisons are only available if the test was statistically significant.")
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
      strong(if (pval < 0.05) "Statistically significant difference in the distribution between groups." else "No statistically significant difference in the distribution between groups.")
    )
  }

  stat_square_fisher <- function(tab) {
    if (any(dim(tab) < 2)) return(NULL)
    res <- tryCatch(rstatix::fisher_test(tab), error = function(e) NULL)
    if (is.null(res)) return(NULL)
    pval <- res$p[1]
    if (is.na(pval)) return(NULL)
    div(
      style = paste0(
        "background-color: ", if (pval < 0.05) "green" else "#B20D00",
        "; color: white; padding: 10px; border-radius: 5px; margin-top: 10px;"
      ),
      strong(if (pval < 0.05) "Statistically significant difference in the distribution between groups." else "No statistically significant difference in the distribution between groups.")
    )
  }

  output$fisher_chisq_square <- renderUI({
    if (invalid_fisher_square()) return(NULL)
    if (!run_fisher_clicked()) return(NULL)
    req(fisher_data(), input$cat1, input$cat2, input$test_type_fisher)
    df <- fisher_data()
    # Filter by timepoint if needed
    if (!is.null(input$fisher_timepoint) && input$fisher_timepoint != "" && "timepoint" %in% names(df)) {
      df <- dplyr::filter(df, timepoint == input$fisher_timepoint)
    }
    
    df[[input$cat1]] <- as.factor(df[[input$cat1]])
    df[[input$cat2]] <- as.factor(df[[input$cat2]])
    tab <- tryCatch({
      df %>%
        dplyr::select(.data[[input$cat1]], .data[[input$cat2]]) %>%
        tidyr::drop_na() %>%
        table()
    }, error = function(e) NULL)
    
    # Always show the square, even if tab is NULL or invalid
    if (is.null(tab) || any(dim(tab) < 2)) {
      return(
        div(
          style = "background-color: #B20D00; color: white; padding: 10px; border-radius: 5px; margin-top: 10px;",
          strong("No Statistically Significant Difference")
        )
      )
    }
    
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
    plot_fisher_clicked(TRUE)
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
      tidyr::drop_na() %>% 
      dplyr::group_by(.data[[input$cat1]]) %>%
      dplyr::mutate(freq = n / sum(n) * 100) %>%
      dplyr::ungroup()

    output$fisher_plot <- renderPlot({
      n_fill <- length(unique(plot_df[[input$cat2]]))
      p <- ggplot2::ggplot(
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
        ggplot2::ylab("Proportion (%)") +
        theme(axis.text.x = element_text(size = 12, angle = 45, vjust = 1, hjust = 1, colour = "black")) +
        theme(axis.text.y = element_text(size = 12, colour = "black")) +
        theme(axis.title.y = element_text(size = 14, face = "bold", colour = "black")) +
        theme(legend.text=element_text(size=12)) + 
        theme(legend.title = element_text(face = "bold", size = 14),legend.text=element_text(size = 12)) 
      if (n_fill <= 8) {
        p <- p + scale_fill_brewer(palette = "Set2") + scale_color_brewer(palette = "Set2")
      }
      p
    })
    # Show download button after plot is made
    shinyjs::show("download_fisher_plot")
    
    output$dynamic_download_fisher <- renderUI({
      downloadButton("download_fisher_plot", "Download Plot")
    })
  })

  output$dynamic_fisher_plot <- renderUI({
    if (!plot_fisher_clicked()) return(NULL)
    plotOutput("fisher_plot")
  })
  
# If the user changes variables or uploads a new file, hide the button again
  plot_fisher_clicked <- reactiveVal(FALSE)
  plot_fisher_clicked(FALSE)
  observeEvent(list(input$file_fisher, input$cat1, input$cat2), {
    shinyjs::hide("download_fisher_plot")
    output$fisher_plot <- renderPlot({ NULL }) # optional: clear plot
    output$dynamic_download_fisher <- renderUI({ NULL })
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
      plot_width <- max(4, n_cats * 0.5 + ceiling(n_fill / 10) * 1.5)
      plot_height <- max(4, n_fill * 0.2 + 4)

      p <- ggplot2::ggplot(
        plot_df,
        ggplot2::aes(x = .data[[input$cat1]], y = freq, fill = .data[[input$cat2]])
      ) +
        ggplot2::geom_bar(stat = "identity", col = "black") +
        ggplot2::theme_test() +
        ggplot2::xlab("") +
        ggplot2::ylab("Proportion (%)") +
        ggplot2::theme(
          axis.text.x = ggplot2::element_text(size = 12, angle = 45, vjust = 1, hjust = 1, colour = "black"),
          axis.text.y = ggplot2::element_text(size = 12, colour = "black"),
          axis.title.y = ggplot2::element_text(size = 14, colour = "black", face = "bold"),
          legend.title = ggplot2::element_text(face = "bold", size = 14),
          legend.text = ggplot2::element_text(size = 12)
        )
      if (n_fill <= 8) {
        p <- p + scale_fill_brewer(palette = "Set2") + scale_color_brewer(palette = "Set2")
      }

      ggplot2::ggsave(file, plot = p, width = plot_width, height = plot_height, dpi = 600, bg = "white")
    }
  )

  output$chi_fisher_warning <- renderUI({
    if (fisher_computational_error()) return(NULL)
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
          tags$br(),
          tags$b("Some expected frequencies < 5."),
          "Chi-squared approximation may be invalid. Consider using ",
          tags$b("Fisher\'s Exact Test"),
          " instead."
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
  
  mvn_res_val <- reactiveVal(NULL)
  clr_block_reason <- reactiveVal(NULL)
  
  cor_assumptions_checked <- reactiveVal(FALSE)
  last_feature_count <- reactiveVal(NULL)
  
  # --- PATCH 0:  ---
  is_singular_matrix <- function(S, tol = .Machine$double.eps^0.5) {
    if (!is.matrix(S)) return(TRUE)
    if (any(!is.finite(S))) return(TRUE)
    r <- qr(S)$rank
    p <- ncol(S)
    (r < p) || any(is.na(S)) || (min(abs(eigen(S, symmetric = TRUE, only.values = TRUE)$values)) < tol)
  }
  
  

  observe({
    session$onFlushed(function() {
      session$sendCustomMessage("reinit-tooltips", list())
    }, once = FALSE)
  })
  
  # Helper: did outlier screen pass?
  cor_outliers_passed <- reactive({
    res <- car_outliers_val()
    is.list(res) && !is.null(res$status) && identical(res$status, "clean")
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
    
    # BLOCK: Too many features selected after prevalence filtering
    n_filtered <- ncol(cor_selected_data())
    previous_count <- last_feature_count()
    
    if (n_filtered > 100) {
      showNotification(
        strong(
          paste0(
            "After removing features with zero variance or all missing values, ",
            "you have ", n_filtered, " features available for analysis. ",
            "Please reduce to 100 or fewer using the prevalence filter or manual selection before running the analysis."
          )
        ),
        type = "error", duration = 10
      )
      last_feature_count(n_filtered)
      return()
    } else {
      # Only show this message if the previous run had >100 and now is <=100
      if (!is.null(previous_count) && previous_count > 100 && n_filtered <= 100) {
        showNotification(
          strong(
            paste0(
              "Now you have ", n_filtered, " features. ",
              "You can proceed to check the correlation."
            )
          ),
          type = "message", duration = 6
        )
      }
      last_feature_count(n_filtered)
    }
    
    updateTabsetPanel(session, inputId = "cor_tabs", selected = "Test Results")
    
    
    
    if (isTRUE(input$cor_do_clr) && is.null(cor_clr_data()) && !is.null(clr_block_reason())) {
      showModal(modalDialog(
        div(
          style = "background-color:#f8d7da; color:#721c24; border:1px solid #f5c6cb; padding:16px; border-radius:6px; font-size:1.05em;",
          icon("exclamation-circle", lib = "font-awesome"),
          strong(" "), clr_block_reason()
        ),
        easyClose = TRUE
      ))
      return()
    }
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
              paste0("Your data has ", n_feat, " features. Correlation analysis with high-dimensional, sparse data (many zeros) may yield statistically unreliable results.")
            ),
            tags$li("Please manually select features or use", strong("'Select All'"), "and adjust the", strong("prevalence slider."), "Click,", strong("'Run Correlation'"), "to see if you meet the feature limit or need to filter further."),
            tags$li("Downloading the full correlation matrix/table (100 features) may take up to 30 seconds. Please wait after clicking the download button.")
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
      options = list(maxItems = Inf, server = T)
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
    
    # Keep only features present in current df
    valid_feats <- intersect(input$cor_features, names(df))
    if (length(valid_feats) == 0) return(NULL)
    df <- df %>% dplyr::select(dplyr::all_of(valid_feats))
    
    # Subset to selected features
    #df <- df %>% dplyr::select(dplyr::all_of(input$cor_features))

    # Optional prevalence filter
    if (!is.null(input$cor_prev_filter) && input$cor_prev_filter > 0) {
      keep <- sapply(df, function(x) mean(x > 0, na.rm = TRUE) >= input$cor_prev_filter / 100)
      df <- df[, keep, drop = FALSE]
    }

    # Remove features with all NA or zero variance
    df <- df[, sapply(df, function(x) !all(is.na(x)) && stats::sd(x, na.rm = TRUE) > 0), drop = FALSE]
    df
  })
  
  
  
  # Reactive: filtered feature count
  cor_n_features <- reactive({
    df <- cor_selected_data()
    if (is.null(df)) return(0)
    ncol(df)
  })
  
  # For use in conditionalPanel
  output$cor_too_many_features <- reactive({
    cor_n_features() > 100
  })
  outputOptions(output, "cor_too_many_features", suspendWhenHidden = FALSE)
  

  # --- CLR transformation (optional) ---
  cor_clr_data <- reactive({
    df <- cor_selected_data()
    if (is.null(df)) return(NULL)
    
    # reset reason
    clr_block_reason(NULL)
    
    # If CLR not requested, just return numeric subset after basic cleaning
    if (!isTRUE(input$cor_do_clr) || ncol(df) <= 1) return(df)
    
    # Only numeric, and replace zeros with a small positive value
    df_num <- df %>%
      dplyr::select(where(is.numeric)) %>%
      dplyr::mutate(across(everything(), ~replace(.x, .x == 0, 0.0001)))
    
    # Block if any negatives or non-positive values remain
    if (any(df_num <= 0, na.rm = TRUE)) {
      clr_block_reason("CLR is not suitable: data contain negative values. Disable CLR or transform your data.")
      #showNotification(strong("CLR: All values must be strictly positive. Disable CLR or fix your data."), type = "error")
      return(NULL)
    }
    
    # Safe CLR
    df_clr <- compositions::clr(as.matrix(df_num)) %>% as.data.frame()
    colnames(df_clr) <- colnames(df_num)
    df_clr
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
          "You have either checked Pearson assumptions for only two variables, or skipped assumption checks for pairwise comparisons. Ensure that assumptions are tested for all pairs; otherwise, the validity of results cannot be guaranteed."
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

    mvn_res <- "Bivariate normality test not run."
    
    if (isTRUE(input$cor_do_clr)) {
      mvn_res <- "Bivariate normality not applicable after CLR."
      mvn_p <- NA
      mvn_ok <- FALSE
    } else if (nrow(df2) < 3 || ncol(df2) != 2) {
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
        mvn_res <- paste0("HZ test p-value: ", signif(mvn_p, 4))
      } else {
        mvn_p <- NA
        mvn_ok <- FALSE
        mvn_res <- "Bivariate normality test could not be computed (e.g., too few samples, collinearity, or invalid data)."
      }
    }
    
    
    mvn_p_val(mvn_p)
    mvn_ok_val(mvn_ok)
    mvn_res_val(mvn_res)


    # --- Outliers (Mahalanobis bivariate screen for Pearson)
    lm_model <- lm(v2 ~ v1)
    alpha_out <- 0.01
    df2_maha <- df %>%
      dplyr::select(all_of(input$cor_features)) %>%
      stats::na.omit() %>%
      as.data.frame()
    
    if (nrow(df2_maha) < 5) {
      car_outliers_val(list(
        status = "na",
        alpha = alpha_out,
        n = NA_integer_,
        idx = integer(0),
        D2 = numeric(0),
        p = numeric(0),
        message = "Screen not applicable: fewer than 5 complete observations."
      ))
    } else {
      S <- stats::cov(df2_maha)
      singular_cov <- is_singular_matrix(S)
      
      if (isTRUE(input$cor_do_clr) && ncol(df2_maha) == 2) singular_cov <- TRUE
      
      if (singular_cov) {
        car_outliers_val(list(
          status = "na",
          alpha = alpha_out,
          n = NA_integer_,
          idx = integer(0),
          D2 = numeric(0),
          p = numeric(0),
          message = "Screen not applicable: singular or ill-conditioned covariance (e.g., CLR with 2 variables)."
        ))
      } else {
        # Safe Mahalanobis with tryCatch
        mah <- tryCatch({
          D2 <- stats::mahalanobis(df2_maha, colMeans(df2_maha), S)
          pvals <- stats::pchisq(D2, df = ncol(df2_maha), lower.tail = FALSE)
          idx <- which(pvals < alpha_out)
          list(D2 = D2, p = pvals, idx = idx)
        }, error = function(e) NULL)
        
        if (is.null(mah)) {
          car_outliers_val(list(
            status = "na",
            alpha = alpha_out,
            n = NA_integer_,
            idx = integer(0),
            D2 = numeric(0),
            p = numeric(0),
            message = "Screen not applicable: failed to compute Mahalanobis distance."
          ))
        } else {
          car_outliers_val(list(
            status = if (length(mah$idx) > 0) "outliers" else "clean",
            alpha = alpha_out,
            n = length(mah$idx),
            idx = mah$idx,
            D2 = mah$D2[mah$idx],
            p = mah$p[mah$idx],
            message = NULL
          ))
        }
      }
    }

    # --- Homoscedasticity
    perf_het <- tryCatch({
      performance::check_heteroscedasticity(lm_model)
    }, error = function(e) NULL)
    perf_het_val(perf_het)

    # --- Results UI
    output$cor_assumption_content <- renderUI({
      req(input$cor_features)
      
      if (isTRUE(input$cor_do_clr) && is.null(cor_clr_data()) && !is.null(clr_block_reason())) {
        return(div(
          style = "background-color:#f8d7da; color:#721c24; border:1px solid #f5c6cb; padding:16px; border-radius:6px; margin-top:10px;",
          icon("exclamation-circle", lib = "font-awesome"),
          strong(" "), clr_block_reason()
        ))
      }
      
      # Show nothing if method is not selected
      if (is.null(input$cor_method) || input$cor_method == "") return(NULL)
      
      # Only apply logic below for Pearson
      if (input$cor_method != "pearson") {
        # Show message ONLY if user tried to check assumptions (button clicked)
        if (cor_assumptions_checked()) {
          return(div(style = "color: #333; background-color:#f5f5f5; margin-top:12px;",
                     strong("Assumption checks only apply for Pearson correlation.")))
        }
        return(NULL)
      }
      

      # Only for Pearson: if not exactly two features, show this message
      if (length(input$cor_features) != 2) {
        return(div(style = "background-color:#f5f5f5; color:#333; padding:18px; border-radius:8px; margin-top:10px;",
                   icon("exclamation-circle", lib = "font-awesome"),
                   strong("Select exactly two features to check assumptions, or click 'Run Correlation' for the full matrix.")))
      }
      
      # Defensive: If any assumption objects are NULL, tell the user to check assumptions.
      if (
        is.null(shap1_val()) || is.null(shap2_val()) || is.null(mvn_p_val()) ||
        is.null(mvn_ok_val()) || is.null(car_outliers_val()) || is.null(perf_het_val())
      ) {
        return(div(style = "background-color:#f5f5f5; color:#333; padding:18px; border-radius:8px; margin-top:10px;",
                   icon("exclamation-circle", lib = "font-awesome"),
                   strong("Select exactly two features to check assumptions, or click 'Run Correlation' for the full matrix.")
        ))
      }
      
      tagList(
        #h4("Assumption Checks"),

        # 1. Linearity
        div(
          br(),
          h5(HTML("<b>1. Linearity (scatterplot)</b> <i
    class='fa-solid fa-circle-info'
    data-bs-toggle='tooltip'
    data-bs-placement='right'
    title='This scatterplot shows the relationship between the two selected variables. The orange line represents a linear regression fit. If the points closely follow the line, the linearity assumption is reasonable; large deviations suggest the assumption may not hold.'
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
        h5(strong("2. Shapiro-Wilk Normality")),
        uiOutput("cor_shapiro_text"),
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
        h5(strong("3. Bivariate Normality (Henze-Wagner test)")),
        uiOutput("cor_mvn_text"),
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
        # 4. Mahalanobis Outlier Test (Bivariate)
        div(
          h5(HTML("<b>4. Mahalanobis Outlier Test (Bivariate)</b> <i
    class='fa-solid fa-circle-info'
    data-bs-toggle='tooltip'
    data-bs-placement='right'
    title='Points are flagged as outliers if their probability is below α (default 0.01). A stricter 0.01 cutoff is used instead of 0.05 to reduce false positives, so only strong outliers are flagged.'
    style='color:#2c3e50; cursor:pointer; font-size:16px; margin-left:10px;'></i>"))
        ),
        uiOutput("cor_outlier_text"),
        uiOutput("cor_outlier_badge"),
        br(),



        # 5. Homoscedasticity
        h5(strong("5. Homoscedasticity")),
        uiOutput("cor_het_text"),
        uiOutput("cor_het_box"),
        br(),
        h4(strong("Assumption Check Summary")),
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
    
    output$cor_shapiro_text <- renderUI({
      tbl <- data.frame(
        Variable = c(input$cor_features[1], input$cor_features[2]),
        `Shapiro-Wilk p` = c(
          if (!is.null(shap1_val())) signif(shap1_val()$p.value, 3) else NA,
          if (!is.null(shap2_val())) signif(shap2_val()$p.value, 3) else NA
        )
      )
      
      tbl_html <- knitr::kable(tbl, align = "c", format = "html") %>% 
        kableExtra::kable_styling(
          bootstrap_options = c("hover", "condensed", "bordered"),
          position = "center", full_width = TRUE
        ) %>% 
        kableExtra::scroll_box(width = "100%", height = "100%")
      
      div(style = "margin-top: 15px;", HTML(tbl_html))
    })
    


    # Bivariate
    output$cor_mvn_text <- renderUI({
      val <- mvn_p_val()
      res <- mvn_res_val()
      
      if (!is.null(val) && !is.na(val)) {
        div(
          style = "background-color:#F5F5F5; color:black; font-size:1em;
               border:1.5px solid #B3B3B3; border-radius:8px; padding:14px 18px; margin-bottom:8px;",
          sprintf("HZ test p-value: %.4g", val)
        )
      } else if (!is.null(res)) {
        div(
          style = "background-color:#F5F5F5; color:black; font-size:1em;
               border:1.5px solid #B3B3B3; border-radius:8px; padding:14px 18px; margin-bottom:8px;",
          res
        )
      } else {
        div(
          style = "background-color:#F5F5F5; color:black; font-size:1em;
               border:1.5px solid #B3B3B3; border-radius:8px; padding:14px 18px; margin-bottom:8px;",
          "Bivariate normality test not run."
        )
      }
    })
    
    
    

    output$cor_outlier_text <- renderUI({
      res <- car_outliers_val()
      if (is.null(res)) return(NULL)
      if (identical(res$status, "na")) {
        return(div(
          style = "background-color:#F5F5F5; color:black; font-size:1em;
               border:1.5px solid #B3B3B3; border-radius:8px; padding:14px 18px; margin-bottom:8px;",
          res$message
        ))
      }
      if (identical(res$status, "clean")) {
        return(div(
          style = "background-color:#F5F5F5; color:black; font-size:1em;
               border:1.5px solid #B3B3B3; border-radius:8px; padding:14px 18px; margin-bottom:8px;",
          sprintf("No bivariate outliers detected at α = %.3f.", res$alpha)
        ))
      }
      # outliers detected
      tbl <- NULL
      if (!is.null(res$idx) && length(res$idx) > 0) {
        tbl <- data.frame(
          row_id = res$idx,
          D2 = signif(res$D2, 4),
          p_value = signif(res$p, 4)
        )
        tbl_html <- knitr::kable(tbl, align = "c", format = "html") %>% 
          kableExtra::kable_styling(bootstrap_options = c("hover", "condensed", "bordered"),
                                    position = "center", full_width = TRUE) %>% 
          kableExtra::scroll_box(width = "100%", height = "100%")
      }
      div(
        style = "background-color:#F5F5F5; color:black; font-size:1em;
             border:1.5px solid #B3B3B3; border-radius:8px; padding:14px 18px; margin-bottom:8px;",
        HTML(sprintf("Outliers detected at α = %.3f (n = %d). Even a few points can bias Pearson.",
                     res$alpha, res$n)),
        if (!is.null(tbl)) HTML(tbl_html)
      )
    })
    
    output$cor_outlier_badge <- renderUI({
      res <- car_outliers_val()
      if (is.null(res)) return(NULL)
      bg <- if (identical(res$status, "clean")) "green" else if (identical(res$status, "outliers")) "#B20D00" else "#666666"
      msg <- if (identical(res$status, "clean")) "No outliers detected."
      else if (identical(res$status, "outliers")) "Outliers detected."
      else "Screen not applicable."
      div(style = paste0("background-color:", bg, "; color:white; padding:5px; border-radius:5px;"), msg)
    })
    
    
    output$cor_het_text <- renderUI({
      if (!is.null(perf_het)) {
        div(
          style = "background-color:#F5F5F5; color:black; font-size:1em;
               border:1.5px solid #B3B3B3; border-radius:8px; padding:14px 18px; margin-bottom:8px; white-space:pre-wrap;",
          paste(capture.output(print(perf_het)), collapse = "\n")
        )
      } else {
        div(
          style = "background-color:#F5F5F5; color:black; font-size:1em;
               border:1.5px solid #B3B3B3; border-radius:8px; padding:14px 18px; margin-bottom:8px;",
          "Test failed."
        )
      }
    })
    

  })

  cor_assumption_summary <- reactive({
    pass_linearity <- !is.null(scatter_plot_val())
    pass_normality <- safe_shapiro_pval(shap1_val()) && safe_shapiro_pval(shap2_val()) &&
      shap1_val()$p.value > 0.05 && shap2_val()$p.value > 0.05
    pass_bivnorm  <- !is.na(mvn_p_val()) && isTRUE(mvn_ok_val())
    pass_outliers <- isTRUE(cor_outliers_passed())

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
    ggplot2::ggplot(data.frame(x = v1, y = v2), aes(x, y)) +
      geom_point(size = 2, color = "#4B96CB") +
      geom_smooth(method = "lm", se = FALSE, color = "#F57B13", linetype = 5, linewidth = 1) +
      theme_bw() +
      labs(title = "Scatterplot with Regression Line",
           x = var1_name, y = var2_name) + 
      theme(axis.text.x = element_text(size = 12, colour = "black")) + 
      theme(axis.title.x = element_text(size = 14, colour = "black", face = "bold")) + 
      theme(axis.text.y = element_text(size = 12, colour = "black")) + 
      theme(axis.title.y = element_text(size = 14, colour = "black", face = "bold")) + 
      theme(plot.title = element_text(size = 17))
  }

 # Download the Scatter plot
  output$cor_download_plot <- downloadHandler(
    filename = function() { paste0("scatter_plot_", Sys.Date(), ".png") },
    content = function(file) {
      df <- cor_clr_data()
      v1 <- df[[input$cor_features[1]]]
      v2 <- df[[input$cor_features[2]]]
      p <- make_scatter_plot(v1, v2, input$cor_features[1], input$cor_features[2])
      ggsave(file, plot = p, width = 6, height = 5, dpi = 600)
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
    if (cor_n_features() > 100) return(NULL)
    req(input$cor_run)
    valid_methods <- c("pearson", "spearman", "kendall", "biweight")
    if (!(input$cor_method %in% valid_methods)) return(NULL)
    
    
    if (isTRUE(input$cor_do_clr) && is.null(cor_clr_data()) && !is.null(clr_block_reason())) {
      return(div(
        style = "background-color:#f8d7da; color:#721c24; border:1px solid #f5c6cb; padding:16px; border-radius:6px; margin-top:10px;",
        icon("exclamation-circle", lib = "font-awesome"),
        strong(" "), clr_block_reason()
      ))
    }
    

    n_feat <- length(input$cor_features)
    
    # Only if actual correlation table will be displayed:
    tagList(
      uiOutput("cor_table_title"),  # Show title/tooltip ONLY with the table
      DT::dataTableOutput("cor_table")
    )

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
      pass_outliers <- isTRUE(cor_outliers_passed())
      
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
              strong("This test is not suitable for your data as its assumptions are not met. Please choose Spearman, Kendall, or bicor correlation instead"))
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
        "Please ensure that assumptions are tested for all pairs; otherwise, results may not be valid."
      )
    }

    table_output <- if (n_feat <= 20) {
      DT::dataTableOutput("cor_table")
    } else {
      div(
        style = "background-color:#fff3cd; color:#856404; padding:14px; border:1px solid #ffeeba; border-radius:5px; margin-top:8px; margin-bottom:12px;",
        icon("exclamation-triangle", lib = "font-awesome"),
        strong("You selected more than 20 features. View full results by downloading tables below.")
      )
      
    }

    tagList(warn_msg, table_output)
  })

  # Correlation interpretation
  output$cor_table_title <- renderUI({
    # Only show if correlation table is actually produced
    if (cor_n_features() > 100) return(NULL)
    if (is.null(input$cor_run) || input$cor_run == 0) return(NULL)
    valid_methods <- c("pearson", "spearman", "kendall", "biweight")
    if (!(input$cor_method %in% valid_methods)) return(NULL)
    if (length(input$cor_features) < 2) return(NULL)
    
    # Check for Pearson + 2 vars: require assumptions passed
    if (input$cor_method == "pearson" && length(input$cor_features) == 2) {
      assumptions_tested <- !is.null(shap1_val()) &&
        !is.null(shap2_val()) &&
        !is.null(mvn_p_val()) && !is.null(mvn_ok_val()) &&
        !is.null(car_outliers_val()) && !is.null(perf_het_val())
      if (!assumptions_tested) return(NULL)
      
      # Must also pass all assumptions
      pass_linearity <- !is.null(scatter_plot_val())
      pass_normality <- safe_shapiro_pval(shap1_val()) && safe_shapiro_pval(shap2_val()) &&
        shap1_val()$p.value > 0.05 && shap2_val()$p.value > 0.05
      pass_bivnorm <- !is.na(mvn_p_val()) && isTRUE(mvn_ok_val())
      pass_outliers <- isTRUE(cor_outliers_passed())
      
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
      pass_all <- all(c(pass_linearity, pass_normality, pass_bivnorm, pass_outliers, pass_het))
      if (!pass_all) return(NULL)
    }
    
    # Only show title/tooltip if output$cor_table will show a real table
    fluidRow(
      column(
        12,
        div(
          style = "display: flex; align-items: center; margin-bottom: 12px; margin-top: 12px;",
          h4(strong("Correlation Interpretation"), style = "margin: 0;"),
          tags$span(
            icon("info-circle", class = "fa-solid"),
            `data-bs-toggle` = "tooltip",
            `data-bs-placement` = "right",
            title = "Strength of correlation:\n
• Pearson r / Spearman rho / bicor r:\n - 0.00–0.10: negligible\n - 0.10–0.30: weak\n - 0.30–0.50: moderate\n - 0.50–0.70: strong\n - 0.70–1.00: very strong\n
• Kendall's tau:\n - 0.00–0.06: negligible\n - 0.06–0.20: weak\n - 0.20–0.40: moderate\n - 0.40–0.60: strong\n - 0.60–1.00: very strong\n
• Positive (+): variables increase together\n • Negative (–): one variable increases as the other decreases.",
            class = "no-print",
            style = "margin-left:8px; color: black; cursor: pointer;"
          )
        )
      )
    )
  })
  
  
  
  
 


  # Table Output Logic
  output$cor_table <- DT::renderDataTable({
    if (cor_n_features() > 100) return(NULL)
    req(input$cor_run)

    valid_methods <- c("pearson", "spearman", "kendall", "biweight")
    if (!(input$cor_method %in% valid_methods)) return(NULL)

    df <- cor_clr_data()
    if (isTRUE(input$cor_do_clr) && is.null(df) && !is.null(clr_block_reason())) return(NULL)
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
    
    # INSERT after valid_methods checks
    if (isTRUE(input$cor_do_clr) && is.null(cor_clr_data()) && !is.null(clr_block_reason())) {
      return(div(
        style = "background-color:#f8d7da; color:#721c24; border:1px solid #f5c6cb; padding:16px; border-radius:6px; margin-top:10px;",
        icon("exclamation-circle", lib = "font-awesome"),
        strong(" "), clr_block_reason()
      ))
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
      pass_outliers <- isTRUE(cor_outliers_passed())
      
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

    if (n_feat <= 20) {
      DT::dataTableOutput("cor_matrix")
    } else {
      div(style="color:#a00; margin-top:8px;",
          "Matrix format available for ≤10 features only. Download the matrix below for full results.")
    }
  })

  # Show the correlation matrix
  output$cor_matrix <- DT::renderDataTable({
    if (cor_n_features() > 100) return(NULL)
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
      pass_outliers <- isTRUE(cor_outliers_passed())
      
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
  if (cor_n_features() > 100) return(NULL)
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
    pass_outliers <- isTRUE(cor_outliers_passed())
    
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
    if (cor_n_features() > 100) return(NULL)
    req(input$cor_run)
    valid_methods <- c("pearson", "spearman", "kendall", "biweight")
    if (!(input$cor_method %in% valid_methods)) return(NULL)
    
    # NULL-safe fetch
    df_clr <- cor_clr_data()
    if (isTRUE(input$cor_do_clr) && is.null(df_clr) && !is.null(clr_block_reason())) {
      return(div(
        style = "background-color:#f8d7da; color:#721c24; border:1px solid #f5c6cb; padding:16px; border-radius:6px; margin-top:10px;",
        icon("exclamation-circle", lib = "font-awesome"),
        strong(" "), clr_block_reason()
      ))
    }
    if (is.null(df_clr)) return(NULL)

    #n_feat <- length(input$cor_features)
    n_feat <- ncol(cor_clr_data())

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



# Plot heatmap
  heatmap_error_msg <- reactiveVal(NULL) 
  heatmap_failed <- reactiveVal(FALSE)
  
  output$cor_heatmap <- renderPlot({
    if (cor_n_features() > 100) return(NULL)
    req(input$cor_run)
    heatmap_error_msg(NULL)  # clear previous message
    heatmap_failed(FALSE)    # reset flag
    
    valid_methods <- c("pearson", "spearman", "kendall", "biweight")
    if (!(input$cor_method %in% valid_methods)) return(NULL)
    
    df <- cor_clr_data()
    #n_feat <- length(input$cor_features)
    
    if (isTRUE(input$cor_do_clr) && is.null(df) && !is.null(clr_block_reason())) {
      heatmap_error_msg(div(
        style = "background-color:#f8d7da; color:#721c24; border:1px solid #f5c6cb; padding:16px; border-radius:6px; margin-top:16px; font-size:1.08em;",
        icon("exclamation-circle", lib = "font-awesome"),
        strong(" "), clr_block_reason()
      ))
      heatmap_failed(TRUE)
      return(NULL)
    }
    if (is.null(df)) return(NULL)
    
    n_feat <- ncol(df)
    if (is.null(n_feat) || is.na(n_feat)) return(NULL)
    if (n_feat < 5 || n_feat > 20) return(NULL)
    
    # Calculate correlation matrix
    cormat <- correlation::correlation(df, method = input$cor_method, p_adjust = input$cor_p_adjust) %>%
      summary(redundant = TRUE)
    cormat_mat <- as.matrix(cormat[,-1])
    rownames(cormat_mat) <- cormat[,1]
    
    # Calculate p-values matrix
    corp <- correlation::correlation(df, method = input$cor_method, p_adjust = input$cor_p_adjust, 
                                     redundant = T) %>% as.data.frame() %>% 
      dplyr::select(Parameter1, Parameter2, p) %>% 
      tidyr::pivot_wider(names_from = Parameter2, values_from = p) %>% 
      tibble::column_to_rownames("Parameter1") %>% base::as.matrix()
    
    
    tl_size <- ifelse(n_feat > 15, 1.4, ifelse(n_feat > 10, 1.4, 1.4))
    cl_size <- ifelse(n_feat > 15, 1.3, ifelse(n_feat > 10, 1.4, 1.4))
    pch_size <- ifelse(n_feat > 15, 1.2, ifelse(n_feat > 10, 1.8, 1.6))
    
    tryCatch({
      if (input$show_significance) {
        corrplot::corrplot(
          cormat_mat, p.mat = corp, type = "lower", na.label = NA, outline = TRUE, 
          order = "hclust", tl.cex = tl_size, cl.cex = cl_size, tl.srt = 45, 
          tl.col = "black", cl.ratio = 0.2, insig = 'label_sig', sig.level = c(0.001, 0.01, 0.05),
          method = 'color',
          pch.cex = pch_size, pch.col = "black", col = rev(corrplot::COL2('RdBu', 200)))
      } else {
        corrplot::corrplot(
          cormat_mat, type = "lower", na.label = NA, outline = TRUE, order = "hclust",
          tl.cex = tl_size, cl.cex = cl_size, tl.srt = 45, tl.col = "black", cl.ratio = 0.2,
          method = 'color',
          col = rev(corrplot::COL2('RdBu', 200))
        )
      }
    }, error = function(e) {
      if (grepl("NA/NaN/Inf.*arg 10", conditionMessage(e))) {
        heatmap_error_msg(div(
          style = "background-color:#f8d7da; color:#721c24; border:1px solid #f5c6cb; padding:16px; border-radius:6px; margin-top:16px; font-size:1.08em;",
          icon("exclamation-circle", lib = "font-awesome"),
          strong("Cannot plot heatmap:"),
          "Too many missing values (NA) in the correlation matrix. ",
          "This often occurs with bicor when the data contain many zeros, identical values, ties, or extreme outliers. Try a different correlation method or apply", strong("CLR transformation"), "to your data."
        ))
        heatmap_failed(TRUE)
        return(NULL)
      } else {
        stop(e)
      }
    })
  })
  

  output$heatmap_error <- renderUI({
    heatmap_error_msg()
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
      n_feat <- ncol(df)
      if (is.null(n_feat) || is.na(n_feat)) return(NULL)
      if (n_feat >= 5 && n_feat <= 20) {
        cormat <- correlation::correlation(df, method = input$cor_method, p_adjust = input$cor_p_adjust) %>%
          summary(redundant = TRUE)
        cormat_mat <- as.matrix(cormat[,-1])
        rownames(cormat_mat) <- cormat[,1]
        
        corp <- correlation::correlation(df, method = input$cor_method, p_adjust = input$cor_p_adjust, 
                                         redundant = TRUE) %>% 
          as.data.frame() %>% 
          dplyr::select(Parameter1, Parameter2, p) %>% 
          tidyr::pivot_wider(names_from = Parameter2, values_from = p) %>% 
          tibble::column_to_rownames("Parameter1") %>% 
          as.matrix()
        
        tl_size <- ifelse(n_feat > 15, 1, ifelse(n_feat > 10, 1.1, 1))
        cl_size <- ifelse(n_feat > 15, 1, ifelse(n_feat > 10, 1, 1))
        pch_size <- ifelse(n_feat > 15, 0.9, ifelse(n_feat > 10, 1.2, 1.3))
        
        pdf(file, width = 8, height = 6)
        oldpar <- par(no.readonly = TRUE)
        on.exit({
          par(oldpar)
          dev.off()
        })
        par(mar = c(2, 2, 2, 2))
        
        # --- Conditional significance annotation ---
        if (isTRUE(input$show_significance)) {
          corrplot::corrplot(
            cormat_mat, p.mat = corp, type = "lower", na.label = NA, outline = TRUE, order = "hclust",
            tl.cex = tl_size, cl.cex = cl_size, tl.srt = 45, tl.col = "black", cl.ratio = 0.2,
            insig = 'label_sig', sig.level = c(0.001, 0.01, 0.05), pch.cex = pch_size, pch.col = "black",
            method = 'color',
            col = rev(corrplot::COL2('RdBu', 200))
          )
        } else {
          corrplot::corrplot(
            cormat_mat, type = "lower", na.label = NA, outline = TRUE, order = "hclust",
            tl.cex = tl_size, cl.cex = cl_size, tl.srt = 45, tl.col = "black", cl.ratio = 0.2,
            method = 'color',
            col = rev(corrplot::COL2('RdBu', 200))
          )
        }
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
      # Reset correlation method and adjustment
      updateSelectInput(session, "cor_method", selected = "")
      updateSelectInput(session, "cor_p_adjust", selected = "BH")
      updateCheckboxInput(session, "cor_do_clr", value = FALSE)
      updateSliderInput(session, "cor_prev_filter", value = 0)
      
      # Update features to first two numeric columns
      df <- cor_data()
      req(df)
      num_cols <- names(df)[sapply(df, is.numeric)]
      #num_cols <- cor_numeric_features()
      updateSelectInput(session, "cor_features", selected = num_cols[seq_len(min(2, length(num_cols)))])
      
      # Reset Select All checkbox if present
      if (!is.null(input$cor_select_all)) updateCheckboxInput(session, "cor_select_all", value = FALSE)
      
      # Reset all assumption/test reactiveVals
      shap1_val(NULL)
      shap2_val(NULL)
      mvn_p_val(NULL)
      mvn_ok_val(NULL)
      car_outliers_val(NULL)
      perf_het_val(NULL)
      scatter_plot_val(NULL)
      cor_assumptions_checked(FALSE)
      
      # Switch back to "Assumption Tests" tab
      updateTabsetPanel(session, "cor_tabs", selected = "Assumption Tests")
    })
    

    
    
    
    output$cor_download_heatmap_ui <- renderUI({
      if (cor_n_features() > 100) return(NULL)
      req(input$cor_run)
      valid_methods <- c("pearson", "spearman", "kendall", "biweight")
      if (!(input$cor_method %in% valid_methods)) return(NULL)
      
      df_clr <- cor_clr_data()
      if (isTRUE(input$cor_do_clr) && is.null(df_clr) && !is.null(clr_block_reason())) return(NULL)
      if (is.null(df_clr)) return(NULL)

      #n_feat <- length(input$cor_features)
      n_feat <- ncol(cor_clr_data())

      if (input$cor_method == "pearson" && n_feat == 2) return(NULL)
      if (n_feat < 5 || n_feat > 20) return(NULL)

      tags$div(
        style = "display: flex; align-items: center; gap: 16px;",
        downloadButton("cor_download_heatmap", "Download Heatmap"),
        tags$span(
          icon("info-circle", class = "fa-solid"),
          `data-bs-toggle` = "tooltip",
          `data-bs-placement` = "right",
          title = "Asterisks indicate significance levels:\n• p-value < 0.001 (***)\n• p-value < 0.01 (**)\n• p-value < 0.05 (*)\n
          If asterisks overlap, please use shorter feature names.",
          style = "cursor: pointer; color:#2c3e50;"
        ),
        tags$div(
          style = "margin-top: 13px;",  # Adjust this value (e.g., 8px, 12px) for how far down you want it
          checkboxInput("show_significance", "Show significance", value = TRUE, width = "150px")
        )
      )
      
      
    })





    output$cor_download_table_ui <- renderUI({
      if (cor_n_features() > 100) return(NULL)
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
        pass_outliers <- isTRUE(cor_outliers_passed())
        
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
    
    
    observe({
      n_feat <- cor_n_features()
      if (n_feat > 100) {
        shinyjs::disable("cor_download_table")
        shinyjs::disable("cor_download_heatmap")
        shinyjs::disable("cor_matrix_download")
        shinyjs::disable("cor_download_plot")
        shinyjs::disable("cor_check_assumptions")
      } else {
        shinyjs::enable("cor_download_table")
        shinyjs::enable("cor_download_heatmap")
        shinyjs::enable("cor_matrix_download")
        shinyjs::enable("cor_download_plot")
        if (input$cor_method == "pearson" && length(input$cor_features) == 2) {
          shinyjs::enable("cor_check_assumptions")
        }
      }
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
      readr::read_csv(input$lm_file$datapath, show_col_types = F) %>%
        dplyr::select(
          -dplyr::contains("infant_id", ignore.case = TRUE),
          -dplyr::contains("infantid", ignore.case = TRUE),
          -dplyr::contains("sample_id", ignore.case = TRUE),
          -dplyr::contains("sampleid", ignore.case = TRUE),
          -dplyr::contains("sample", ignore.case = TRUE),
          -dplyr::contains("accession", ignore.case = TRUE),
          -dplyr::contains("name", ignore.case = TRUE)
        )
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
        selectInput("lm_dep", 
                    tagList(
                      "Select dependent variable (continuous):",
                      tags$span(
                        icon("info-circle", class = "fa-solid"),
                        `data-bs-toggle` = "tooltip",
                        `data-bs-placement` = "right",
                        title = "Note: Only continuous variables are shown. Count or discrete variables are excluded, as they violate model assumptions. For count outcomes, please use the Poisson regression option."
                      )),
                    choices = c("Select variable" = "", num_vars),
                    selected = ""),
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

    
    # ---- LM: UI for Dependent Variable transformation ----
    output$lm_transform_ui <- renderUI({
      req(lm_data())  # Ensure data is uploaded/available
      
      selectInput("lm_transform",
                  tagList(
                    "Transform dependent variable (optional):",
                    tags$span(
                      icon("info-circle", class = "fa-solid"),
                      `data-bs-toggle` = "tooltip",
                      `data-bs-placement` = "right",
                      title = "Tip: If the dependent variable is highly skewed or not normally distributed, please apply a transformation before running the test. Use Log or Box-Cox for values > 0. Use Yeo-Johnson or Inverse Normal for variables that include positive values, zeros, or negatives. Always inspect the histogram before and after transformation."
                    )),
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
      selectizeInput("lm_interact", "Add interaction term(s) (optional):",
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

      output$lm_result <- renderUI({
        df <- lm_model_data()
        main_effects <- input$lm_indep
        # If user picked interactions
        interaction_terms <- NULL
        if (!is.null(input$lm_interact) && length(input$lm_interact) > 0) {
          interaction_terms <- gsub(":", " * ", input$lm_interact)  # "A:B" -> "A * B"
        }
        rhs <- c(main_effects, interaction_terms)
        fml <- as.formula(paste(input$lm_dep, "~", paste(rhs, collapse = " + ")))
        
        # >>> INSERTED: fit model and compute fit metrics
        mod <- lm(fml, data = df)
        smry <- summary(mod)
        r2   <- unname(smry$r.squared)
        adjr <- unname(smry$adj.r.squared)
        aic  <- AIC(mod)
        bic  <- BIC(mod)
        rmse <- sqrt(mean(residuals(mod)^2))
        
        tbl_lm <-lm(fml, data = df) %>%
          broom::tidy(conf.int = T) %>%
          dplyr::mutate(Sig = dplyr::case_when(
            is.na(p.value) ~ "",
            p.value < 0.001 ~ "***",
            p.value < 0.01 ~ "**",
            p.value < 0.05 ~ "*",
            TRUE ~ "NS"
          )) %>%
          knitr::kable(align = "c", format = "html") %>% 
          kableExtra::kable_styling(
            bootstrap_options = c("hover", "condensed", "bordered"),
            position = "center", full_width = T) %>% 
          kableExtra::scroll_box(width = "100%", height = "100%")
        
        # >>> INSERTED: model-fit square (heading + quick guidance)
        fit_box <- div(
          style = "margin-top: 14px; background:#f5f7fb; border:1px solid #d9e1f2; border-radius:8px; padding:12px;",
          div(
            style = "display:flex; align-items:center; gap:8px; margin-bottom:8px;",
            tags$strong("Model fit & what to do"),
            tags$span(
              icon("info-circle", class = "fa-solid"),
              `data-bs-toggle` = "tooltip",
              `data-bs-placement` = "right",
              title = "Akaike Information Criterion (AIC)\nBayesian Information Criterion (BIC)\nRoot Mean Square Error (RMSE)\nAdjusted R-squared (Adj. R²)\n\n
Compare models fitted on the same data:\n
• Lower AIC, BIC, and RMSE indicate better fit.\n• Higher adjusted R² indicates better explanatory power.\n
If AIC differs by less than 2, the models fit equally well, so prefer the simpler one.",
              class = "no-print",
              style = "color:black; cursor:pointer;"
            )
          ),
          tags$div(
            style = "display:grid; grid-template-columns: repeat(5, minmax(0,1fr)); gap:8px; font-size:0.95em;",
            tags$div(tags$strong("AIC"),  br(), sprintf("%.2f", aic)),
            tags$div(tags$strong("BIC"),  br(), sprintf("%.2f", bic)),
            tags$div(tags$strong("R²"),   br(), sprintf("%.3f", r2)),
            tags$div(tags$strong("Adj. R²"), br(), sprintf("%.3f", adjr)),
            tags$div(tags$strong("RMSE"), br(), sprintf("%.3f", rmse))
          )
        )
        
        div(
          style = "margin-top: 15px;",
          HTML(tbl_lm),
          fit_box
        )
      })
    })

    
    # Assumptions notes     
    output$note_title_lm <- renderUI({
      req(input$lm_check)
      fluidRow(
        column(
          12,
          div(
            style = "display: flex; align-items: center; margin-bottom: 12px; margin-top: 12px;",
            h4(strong("Tips"), style = "margin: 0;"),
            tags$span(
              icon("info-circle", class = "fa-solid"),
              `data-bs-toggle` = "tooltip",
              `data-bs-placement` = "right",
              title = "Posterior Predictive Check:\n→ If predicted and observed values differ greatly, the model may be misspecified. Try adding or removing predictors, or transforming variables (e.g., log or Box-Cox).\n
Linearity:\n→ If you see curvature, add interaction or transform predictors (e.g., log). Remove predictors that don’t have a linear relationship with the outcome.\n
Homogeneity of Variance:\n→ If the plot shows a funnel shape, transform the dependent variable (log, Box-Cox, or Yeo–Johnson).\n
Influential Observations:\n→ If points fall outside the contour lines, check for data errors and fix them. If correct, test the model with and without those points and report any major differences.\n
Collinearity (VIF plot):\n→ If VIF > 10, remove or combine correlated predictors.\n
Normality of Residuals:\n→ If points deviate strongly from the line (especially in the tails), transform the outcome variable (log, Box-Cox, or Yeo–Johnson).",
              class = "no-print",
              style = "margin-left:8px; color: black; cursor: pointer;"
            )
          )
        )
      )
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

      # LM histogram before transformation
      output$lm_hist_before <- renderPlot({
        shinyjs::show("download_hist_before")
        req(lm_data(), input$lm_dep)
        df <- lm_data()
        ggplot2::ggplot(df, aes(x = .data[[input$lm_dep]])) +
          geom_histogram(aes(y = after_stat(density)), color = "black", fill = "#4db6ac", bins = 30) +
          geom_density(color = "#b2182b", size = 1.2, alpha = 0.7, show.legend = FALSE) +
          theme_test() + 
          theme(axis.title.x = element_text(colour = "black", face = "bold", size = 15)) + 
          theme(axis.title.y = element_text(colour = "black", face = "bold", size = 15)) + 
          theme(axis.text.y = element_text(colour = "black", size = 12)) + 
          theme(axis.text.x = element_text(colour = "black", size = 12)) +
          labs(title = "Before Transformation", x = input$lm_dep, y = "Density") +
          theme(plot.title = element_text(size = 17))
      })
      
      # ---- Shapiro square BEFORE transformation ----
      output$lm_shapiro_square_before <- renderUI({
        req(lm_data(), input$lm_dep)
        df <- lm_data()
        y <- df[[input$lm_dep]]
        # Only apply to numeric, sample size 3-5000
        if (!is.numeric(y) || length(y) < 3 || length(y) > 5000) return(NULL)
        res <- shapiro.test(y)
        shapiro_square(res$p.value, location = "Before")
      })
      

      # LM histogram after transformation
      output$lm_hist_after_ui <- renderUI({
        req(input$lm_check_norm)
        req(input$lm_transform)
        if (input$lm_transform != "none") {
          tagList(
            plotOutput("lm_hist_after"),
            uiOutput("lm_shapiro_square_after"),
            downloadButton("download_hist_after", "Download After")
          )
        }
      })
      
      
      output$lm_hist_after <- renderPlot({
        req(lm_transformed_data(), input$lm_dep)
        df <- lm_transformed_data()
        ggplot2::ggplot(df, aes(x = .data[[input$lm_dep]])) +
          geom_histogram(aes(y = after_stat(density)), color = "black", fill = "#ffb74d", bins = 30) +
          geom_density(color = "#b2182b", size = 1.2, alpha = 0.7, show.legend = FALSE) +
          theme_test() +
          theme(axis.title.x = element_text(colour = "black", face = "bold", size = 15)) + 
          theme(axis.title.y = element_text(colour = "black", face = "bold", size = 15)) + 
          theme(axis.text.y = element_text(colour = "black", size = 12)) + 
          theme(axis.text.x = element_text(colour = "black", size = 12)) +
          labs(title = "After Transformation", x = paste0(input$lm_dep, " (transformed)"), y = "Density") +
          theme(plot.title = element_text(size = 17))
      })
    })

    # ---- Shapiro square AFTER transformation ----
    output$lm_shapiro_square_after <- renderUI({
      req(lm_transformed_data(), input$lm_dep)
      df <- lm_transformed_data()
      y <- df[[input$lm_dep]]
      if (!is.numeric(y) || length(y) < 3 || length(y) > 5000) return(NULL)
      res <- shapiro.test(y)
      shapiro_square(res$p.value, location = "After")
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
        p <- ggplot2::ggplot(df, aes(x = .data[[dep_var]])) +
          geom_histogram(aes(y = after_stat(density)), color = "black", fill = "#4db6ac", bins = 30) +
          geom_density(color = "#b2182b", size = 1.2, alpha = 0.7, show.legend = FALSE) +
          theme_test() + 
          labs(title = "Before Transformation", x = dep_var, y = "Density") +
          theme(
            plot.title = element_text(size = 17),
            axis.title.x = element_text(colour = "black", face = "bold", size = 15),
            axis.title.y = element_text(colour = "black", face = "bold", size = 15),
            axis.text.x = element_text(colour = "black", size = 12),
            axis.text.y = element_text(colour = "black", size = 12)
          )
        ggsave(file, plot = p, width = 8, height = 6, dpi = 600)
      }
    )
    
    
    
    shapiro_square <- function(pval, location = "") {
      if (is.na(pval)) return(NULL)
      
      if (pval > 0.10) {
        color <- "green"
        font_color <- "white"
        msg <- paste0("✓ Normality (Shapiro-Wilk test; p = ", format.pval(pval, digits = 3), ") ")
      } else if (pval > 0.05 && pval <= 0.10) {
        color <- "#ffc107"
        font_color <- "black"   # yellow background → black text
        msg <- paste0("! Borderline normality (Shapiro-Wilk test; p = ", format.pval(pval, digits = 3), ")")
      } else {
        color <- "#B20D00"
        font_color <- "white"
        msg <- paste0("✗ Not normal (Shapiro-Wilk test; p = ", format.pval(pval, digits = 3), ") ")
      }
      
      div(
        style = paste0(
          "background-color:", color, 
          "; color:", font_color, 
          "; padding: 10px; border-radius: 7px; font-size: 1em; margin-top: 8px; margin-bottom: 4px; text-align: center;"
        ),
        strong(msg)
      )
    }
    
    
    
    
    
    

    # Download handler for AFTER transformation
    output$download_hist_after <- downloadHandler(
      filename = function() paste0("hist_after_", Sys.Date(), ".png"),
      content = function(file) {
        req(lm_transformed_data(), input$lm_dep)
        df <- lm_transformed_data()
        p <- ggplot2::ggplot(df, aes(x = .data[[input$lm_dep]])) +
          geom_histogram(aes(y = after_stat(density)), color = "black", fill = "#ffb74d", bins = 30) +
          geom_density(color = "#b2182b", size = 1.2, alpha = 0.7, show.legend = FALSE) +
          theme_test() + 
          labs(title = "After Transformation", x = paste0(input$lm_dep, " (transformed)"), y = "Density") +
          theme(
            plot.title = element_text(size = 17),
            axis.title.x = element_text(colour = "black", face = "bold", size = 15),
            axis.title.y = element_text(colour = "black", face = "bold", size = 15),
            axis.text.x = element_text(colour = "black", size = 12),
            axis.text.y = element_text(colour = "black", size = 12)
          )
        ggsave(file, plot = p, width = 8, height = 6, dpi = 600)
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
      #library(sjPlot)
      b <- sjPlot::get_model_data(mod, type = "est")
      b %>%
        dplyr::mutate(group = dplyr::case_when(
          p.value < 0.05 & estimate > 0 ~ "sig_pos",
          p.value < 0.05 & estimate < 0 ~ "sig_neg",
          TRUE ~ "NS"
        )) %>%
        dplyr::filter(!is.na(conf.low), !is.na(conf.high)) %>%
        ggplot2::ggplot(aes(x = estimate, y = term)) +
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

    # Automatically switch tab when “Plot Forest” is clicked
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
      updateTabsetPanel(session, inputId = "lm_tabs", selected = "Forest Plot")
    })

    # download of the effect plot as PNG
    output$lm_download_effect <- downloadHandler(
      filename = function() paste0("lm_forest_plot_", Sys.Date(), ".png"),
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
        p <- ggplot2::ggplot(b, aes(x = estimate, y = term)) +
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
        selectInput("lmm_dep", 
                    tagList(
                      "Select dependent variable (continuous):",
                      tags$span(
                        icon("info-circle", class = "fa-solid"),
                        `data-bs-toggle` = "tooltip",
                        `data-bs-placement` = "right",
                        title = "Note: Only continuous variables are shown. Count or discrete variables are excluded, as they violate model assumptions. For count outcomes, please use the Poisson regression option."
                      )),
                    choices = c("Select variable" = "", num_vars), selected = ""),
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
        selectizeInput("lmm_interact", "Add interaction term(s) (optional):",
                       choices = c("No available interactions" = ""),
                       multiple = TRUE, selected = "", options = list(disabled = TRUE))
      } else {
        interact_choices <- combn(choices, 2, FUN = function(x) paste(x, collapse = ":"), simplify = TRUE)
        selectizeInput("lmm_interact", "Add interaction term(s) (optional):",
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
    

    # ---- LMM: Random Variable UI ----
    output$lmm_re_ui <- renderUI({
      req(input$lmm_file)
      df <- read.csv(input$lmm_file$datapath)
      fact_vars <- names(df)[sapply(df, function(x) is.factor(x) || is.character(x))]
      indep <- input$lmm_indep
      choices <- setdiff(fact_vars, indep)
      
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
        choices = choices,
        selected = NULL,
        multiple = TRUE,
        options = list(placeholder = 'Select variable')
      )
    })
    
    
    

    # ---- LMM: Dependent Variable Transformation UI ----
    output$lmm_transform_ui <- renderUI({
      req(input$lmm_file)
      selectInput(
        "lmm_transform",
        tagList(
          "Transform dependent variable (optional):",
          tags$span(
            icon("info-circle", class = "fa-solid"),
            `data-bs-toggle` = "tooltip",
            `data-bs-placement` = "right",
            title = "Tip: If the dependent variable is highly skewed or not normally distributed, please apply a transformation before running the test. Use Log or Box-Cox for values > 0.  Use Yeo-Johnson or Inverse Normal for variables that include positive values, zeros, or negatives. Always inspect the histogram before and after transformation.",
            style = "margin-left: 8px; color: #2c3e50; font-size:16px; cursor: pointer;"
          )
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
      
      
      
      lmm_transformed_data <- reactive({
        req(lmm_data(), input$lmm_dep)
        df <- lmm_data()
        y <- df[[input$lmm_dep]]
        method <- input$lmm_transform
        
        if (method == "none") {
          df[[input$lmm_dep]] <- y
        } else if (method == "log") {
          if (any(y <= 0, na.rm = TRUE)) {
            showNotification(strong("Log transform requires all values > 0."), type = "error")
            return(NULL)
          }
          df[[input$lmm_dep]] <- log(y)
        } else if (method == "yeojohnson") {
          df[[input$lmm_dep]] <- bestNormalize::yeojohnson(y)$x.t
        } else if (method == "boxcox") {
          if (any(y <= 0, na.rm = TRUE)) {
            showNotification(strong("Box-Cox transform requires all values > 0."), type = "error")
            return(NULL)
          }
          df[[input$lmm_dep]] <- bestNormalize::boxcox(y)$x.t
        } else if (method == "invnorm") {
          df[[input$lmm_dep]] <- bestNormalize::orderNorm(y)$x.t
        }
        df
      })
      
      
      
      output$lmm_shapiro_square_before <- renderUI({
        req(lmm_data(), input$lmm_dep)
        df <- lmm_data()
        y <- df[[input$lmm_dep]]
        if (!is.numeric(y) || length(y) < 3 || length(y) > 5000) return(NULL)
        res <- shapiro.test(y)
        shapiro_square(res$p.value, location = "Before")
      })
      
      output$lmm_shapiro_square_after <- renderUI({
        req(lmm_transformed_data(), input$lmm_dep)
        df <- lmm_transformed_data()
        y <- df[[input$lmm_dep]]
        if (!is.numeric(y) || length(y) < 3 || length(y) > 5000) return(NULL)
        res <- shapiro.test(y)
        shapiro_square(res$p.value, location = "After")
      })
      

      # Histogram BEFORE transformation
      output$lmm_hist_before <- renderPlot({
        shinyjs::show("lmm_download_hist_before")
        req(lmm_data(), input$lmm_dep)
        df <- lmm_data()
        ggplot2::ggplot(df, aes(x = .data[[input$lmm_dep]])) +
          geom_histogram(aes(y = after_stat(density)), color = "black", fill = "#4db6ac", bins = 30) +
          geom_density(color = "#b2182b", size = 1.2, alpha = 0.7, show.legend = FALSE) +
          theme_test() + 
          theme(axis.title.x = element_text(colour = "black", face = "bold", size = 15)) + 
          theme(axis.title.y = element_text(colour = "black", face = "bold", size = 15)) + 
          theme(axis.text.y = element_text(colour = "black", size = 12)) + 
          theme(axis.text.x = element_text(colour = "black", size = 12)) +
          labs(title = "Before Transformation", x = input$lmm_dep, y = "Density") +
          theme(plot.title = element_text(size = 17))
      })

      shinyjs::hide("lmm_download_hist_before")
      
      
      
      
      
      # Histogram AFTER transformation
      output$lmm_hist_after_ui <- renderUI({
        if (!is.null(input$lmm_transform) && input$lmm_transform != "none") {
          tagList(
            plotOutput("lmm_hist_after"),
            uiOutput("lmm_shapiro_square_after"),
            downloadButton("lmm_download_hist_after", "Download After")
          )
        }
      })
      
      
      output$lmm_hist_after <- renderPlot({
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
        ggplot2::ggplot(plot_df, aes(val)) +
          geom_histogram(aes(y = after_stat(density)), color = "black", fill = "#ffb74d", bins = 30) +
          geom_density(color = "#b2182b", size = 1.2, alpha = 0.7, show.legend = FALSE) +
          theme_test() + 
          theme(axis.title.x = element_text(colour = "black", face = "bold", size = 15)) + 
          theme(axis.title.y = element_text(colour = "black", face = "bold", size = 15)) + 
          theme(axis.text.y = element_text(colour = "black", size = 12)) + 
          theme(axis.text.x = element_text(colour = "black", size = 12)) +
          labs(title = "After Transformation", x = paste0(input$lmm_dep, " (transformed)"), y = "Density") +
          theme(plot.title = element_text(size = 17))
      })
    })

    # Download logic
    output$lmm_download_hist_before <- downloadHandler(
      filename = function() paste0("lmm_hist_before_", Sys.Date(), ".png"),
      content = function(file) {
        req(lmm_data(), input$lmm_dep)
        df <- lmm_data()
        p <- ggplot2::ggplot(df, aes(x = .data[[input$lmm_dep]])) +
          geom_histogram(aes(y = after_stat(density)), color = "black", fill = "#4db6ac", bins = 30) +
          geom_density(color = "#b2182b", size = 1.2, alpha = 0.7, show.legend = FALSE) +
          theme_test() + 
          labs(title = "Before Transformation", x = input$lmm_dep, y = "Density") +
          theme(
            plot.title = element_text(size = 17),
            axis.title.x = element_text(colour = "black", face = "bold", size = 15),
            axis.title.y = element_text(colour = "black", face = "bold", size = 15),
            axis.text.x = element_text(colour = "black", size = 12),
            axis.text.y = element_text(colour = "black", size = 12)
          )
        ggsave(file, plot = p, width = 8, height = 6, dpi = 600)
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
                          "invnorm" = bestNormalize::orderNorm(x)$x.t)
        plot_df <- data.frame(val = trans_x)
        p <- ggplot2::ggplot(plot_df, aes(val)) +
          geom_histogram(aes(y = after_stat(density)), color = "black", fill = "#ffb74d", bins = 30) +
          geom_density(color = "#b2182b", size = 1.2, alpha = 0.7) +
          theme_test() +
          labs(title = "After Transformation", x = paste0(input$lmm_dep, " (transformed)"), y = "Density") +
          theme(
            plot.title = element_text(size = 17),
            axis.title.x = element_text(colour = "black", face = "bold", size = 15),
            axis.title.y = element_text(colour = "black", face = "bold", size = 15),
            axis.text.x = element_text(colour = "black", size = 12),
            axis.text.y = element_text(colour = "black", size = 12)
          )
        ggsave(file, plot = p, width = 8, height = 6, dpi = 600)
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


        
        # Assumptions notes     
        output$note_title_lmm <- renderUI({
          req(input$lmm_check)
          fluidRow(
            column(
              12,
              div(
                style = "display: flex; align-items: center; margin-bottom: 12px; margin-top: 12px;",
                h4(strong("Tips"), style = "margin: 0;"),
                tags$span(
                  icon("info-circle", class = "fa-solid"),
                  `data-bs-toggle` = "tooltip",
                  `data-bs-placement` = "right",
                  title = "Posterior Predictive Check:\n→ If predicted and observed values differ greatly, try adding or removing predictors, or transforming variables (e.g., Box-Cox).\n
Linearity:\n→ If you see curvature, add interaction or transform predictors (e.g., log). Remove predictors that don’t have a linear relationship with the outcome.\n
Homogeneity of Variance:\n→ If the plot shows a funnel shape, transform the dependent variable (e.g., Box-Cox).\n
Influential Observations:\n→ If points fall outside the contour lines, check for data errors and fix them. If correct, test the model with and without those points and report any major differences.\n
Collinearity (VIF plot):\n→ If VIF > 10, remove or combine correlated predictors.\n
Normality of Residuals:\n→ If points deviate strongly from the line (especially in the tails), transform the outcome variable (e.g., Box-Cox or Yeo–Johnson).\n
Normality of Random Effects:\n→ If random effects are non-normal, try a simpler model by removing random effects that don’t add much, or interpret results cautiously.",
                  class = "no-print",
                  style = "margin-left:8px; color: black; cursor: pointer;"
                )
              )
            )
          )
        })
        
        
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
    
    
    

    output$lmm_result <- renderUI({
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
      tbl_lmm <- broom.mixed::tidy(model, conf.int = TRUE) %>%
        dplyr::filter(effect == "fixed") %>%
        dplyr::filter(!term %in% c("sd__(Intercept)", "sd__Observation")) %>%
        dplyr::select(-c(effect, group)) %>%
        dplyr::mutate(Sig = dplyr::case_when(
          is.na(p.value) ~ "",
          p.value < 0.001 ~ "***",
          p.value < 0.01 ~ "**",
          p.value < 0.05 ~ "*",
          TRUE ~ "NS"
        )) %>%
        knitr::kable(align = "c", format = "html") %>% 
        kableExtra::kable_styling(
          bootstrap_options = c("hover", "condensed", "bordered"),
          position = "center", full_width = T) %>% 
        kableExtra::scroll_box(width = "100%", height = "100%")
      
      # --- Fit metrics (LMM) ---
      sing <- lme4::isSingular(model, tol = 1e-4)
      aic  <- AIC(model)
      bic  <- BIC(model)
      rmse <- sqrt(mean(residuals(model)^2))
      
      # Accurate marginal and conditional R² using 'performance'
      r <- performance::r2(model)
      r2_marginal    <- unname(r$R2_marginal)
      r2_conditional <- if (sing) NA_real_ else unname(r$R2_conditional)
      
      
      sing_msg <- if (sing) div(
        style = "margin-bottom:10px; background:#fff3cd; border:1px solid #ffe8a1; border-radius:6px; padding:10px;",
        strong("Singular fit: "),
        "random-effect variance is ~0. Report marginal R² only, and consider simplifying random effects (e.g., remove zero-variance random slopes or unused grouping factors)."
      ) else NULL
      
      
      # --- Model-fit square (heading + tooltip) ---
      fit_box <- div(
        style = "margin-top: 14px; background:#f5f7fb; border:1px solid #d9e1f2; border-radius:8px; padding:12px;",
        div(
          style = "display:flex; align-items:center; gap:8px; margin-bottom:8px;",
          tags$strong("Model fit & what to do"),
          tags$span(
            icon("info-circle", class = "fa-solid"),
            `data-bs-toggle` = "tooltip",
            `data-bs-placement` = "right",
            title = "Akaike Information Criterion (AIC)\nBayesian Information Criterion (BIC)\nRoot Mean Square Error (RMSE)\nMarginal R-squared (R²m)\nConditional R-squared (R²c)\n\n
Compare models fitted on the same data:\n
• Lower AIC, BIC, and RMSE indicate better fit.\n• Higher R²m/R²c indicate better explanatory power.\n
If AIC differs by less than 2, the models fit equally well, so prefer the simpler one.",
            class = "no-print",
            style = "color:black; cursor:pointer;"
          )
        ),
        sing_msg, 
        tags$div(
          style = "display:grid; grid-template-columns: repeat(5, minmax(0,1fr)); gap:8px; font-size:0.95em;",
          tags$div(tags$strong("AIC"),  br(), sprintf("%.2f", aic)),
          tags$div(tags$strong("BIC"),  br(), sprintf("%.2f", bic)),
          tags$div(tags$strong("R²m"), br(), sprintf("%.3f", r2_marginal)),
          tags$div(tags$strong("R²c"), br(), sprintf("%.3f", r2_conditional)),
          tags$div(tags$strong("RMSE"), br(), sprintf("%.3f", rmse))
        )
      )
      
      div(
        style = "margin-top: 15px;", 
        HTML(tbl_lmm),
        fit_box
      )
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
        
        
        updateTabsetPanel(session, inputId = "lmm_tabs", selected = "Forest Plot")
        
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
            dplyr::filter(!term %in% c("sd__(Intercept)", "sd__Observation")) %>%
            dplyr::select(-c(effect, group)) %>%
            dplyr::mutate(group = dplyr::case_when(
              p.value < 0.05 & estimate > 0 ~ "sig_pos",
              p.value < 0.05 & estimate < 0 ~ "sig_neg",
              TRUE ~ "NS"
            )) %>%
            dplyr::filter(term != "(Intercept)")
          ggplot2::ggplot(df, aes(x = estimate, y = term)) +
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
          downloadButton("lmm_download_effect_real", "Download Forest Plot")
        })
        
      })


      # Download forest plot (LMM)
      # Inside observer, after all checks:
      output$lmm_download_effect <- renderUI({
        downloadButton("lmm_download_effect_real", "Download Forest Plot")
      })
      
      output$lmm_download_effect_real <- downloadHandler(
        filename = function() paste0("lmm_forest_plot_", Sys.Date(), ".png"),
        content = function(file) {
          req(lmm_model_plot())
          df <- broom.mixed::tidy(lmm_model_plot(), conf.int = TRUE) %>%
            dplyr::filter(effect == "fixed") %>%
            dplyr::filter(!term %in% c("sd__(Intercept)", "sd__Observation")) %>%
            dplyr::select(-c(effect, group)) %>%
            dplyr::mutate(group = dplyr::case_when(
              p.value < 0.05 & estimate > 0 ~ "sig_pos",
              p.value < 0.05 & estimate < 0 ~ "sig_neg",
              TRUE ~ "NS"
            )) %>%
            dplyr::filter(term != "(Intercept)")
          p <- ggplot2::ggplot(df, aes(x = estimate, y = term)) +
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
        
        ## assign to df first
        df <- readr::read_csv(input$log_file$datapath, show_col_types = FALSE) %>%
          dplyr::select(
            -dplyr::contains("infant_id", ignore.case = TRUE),
            -dplyr::contains("infantid", ignore.case = TRUE),
            -dplyr::contains("sample_id", ignore.case = TRUE),
            -dplyr::contains("sampleid", ignore.case = TRUE),
            -dplyr::contains("sample", ignore.case = TRUE),
            -dplyr::contains("accession", ignore.case = TRUE),
            -dplyr::contains("name", ignore.case = TRUE)
          )
        
        ## now safely transform df
        df[] <- lapply(df, function(col) {
          if (is.character(col)) {
            factor(col)                          
          } else if (is.logical(col)) {
            factor(col)                          
          } else if (is.numeric(col) &&
                     all(col == floor(col), na.rm = TRUE) &&
                     length(unique(col)) <= 15) {
            factor(as.character(col))            
          } else {
            col
          }
        })
        
        df
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
          "log_interact", "Add interaction term(s) (optional):",
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

        output$log_result <- renderUI({
          df <- log_model_data()
          validate(need(!is.null(df), ""))
          
          main_effects <- input$log_indep
          interaction_terms <- NULL
          if (!is.null(input$log_interact) && length(input$log_interact) > 0) {
            interaction_terms <- gsub(":", " * ", input$log_interact)
          }
          rhs <- c(main_effects, interaction_terms)
          fml <- as.formula(paste(input$log_dep, "~", paste(rhs, collapse = " + ")))
          
          # --- Fit the bias-reduced logistic regression model (brglm) ---
          res <- tryCatch({                  ## added tryCatch
            mod <- glm(fml, data = df, family = binomial(), method = "brglmFit")
            broom::tidy(mod, conf.int = TRUE)
          }, error = function(e) NULL)
          
          validate(need(!is.null(res), ""))
          
          
          # >>> INSERTED: Fit metrics (Logistic GLM)
          # AIC/BIC always valid for GLMs; use pseudo-R² for classification models.
          aic <- AIC(mod)
          bic <- BIC(mod)
          ll_full <- as.numeric(logLik(mod))


          # --- Extract tidy summary and check for problematic variables ---
          b <- broom::tidy(mod, conf.int = TRUE)
          problem_vars <- b$term[is.na(b$conf.low) | is.na(b$conf.high) | abs(b$estimate) > 10]
          
          # --- Unified, concise warning (if any problematic variables detected) ---
          if (length(problem_vars) > 0) {
            showNotification(
              div(
                style = "background-color:#fff3cd; color:#856404; padding:14px; border:1px solid #ffeeba; border-radius:5px;",
                icon("exclamation-triangle", lib = "font-awesome"),
                strong("Model warning:"),
                "Model results may be unreliable because ",
                tags$b(paste(problem_vars, collapse = ", ")),
                " perfectly predicts the outcome or is too rare. ",
                "Try removing or merging these variable(s) to resolve this."
              ),
              type = "warning", duration = 20
            )
          }
          
          # --- Prepare and render the summary table ---
          tbl_log <- b %>%
            dplyr::mutate(Sig = dplyr::case_when(
              is.na(p.value) ~ "",
              p.value < 0.001 ~ "***",
              p.value < 0.01 ~ "**",
              p.value < 0.05 ~ "*",
              TRUE ~ "NS"
            )) %>%
            knitr::kable(align = "c", format = "html") %>%
            kableExtra::kable_styling(
              bootstrap_options = c("hover", "condensed", "bordered"),
              position = "center", full_width = T) %>%
            kableExtra::scroll_box(width = "100%", height = "100%")
          
          
          # >>> INSERTED: Model-fit square (Logistic GLM)
          fit_box <- div(
            style = "margin-top: 14px; background:#f5f7fb; border:1px solid #d9e1f2; border-radius:8px; padding:12px;",
            div(
              style = "display:flex; align-items:center; gap:8px; margin-bottom:8px;",
              tags$strong("Model fit & what to do"),
              tags$span(
                icon("info-circle", class = "fa-solid"),
                `data-bs-toggle` = "tooltip",
                `data-bs-placement` = "right",
                title = "AIC (Akaike Information Criterion)
                BIC (Bayesian Information Criterion)
                logLik (log-likelihood)\n\n
                Compare models on the same data.\n
                • Lower AIC and BIC = better fit.
                • Higher logLik = better fit\n
                If AIC differs by less than 2, the models fit equally well, so prefer the simpler model.",
                class = "no-print",
                style = "color:black; cursor:pointer;"
              )
            ),
            tags$div(
              style = "display:grid; grid-template-columns: repeat(5, minmax(0,1fr)); gap:8px; font-size:0.95em;",
              tags$div(tags$strong("AIC"),         br(), sprintf("%.2f", aic)),
              tags$div(tags$strong("BIC"),         br(), sprintf("%.2f", bic)),
              tags$div(tags$strong("logLik"),  br(), sprintf("%.2f", ll_full))
            )
          )
          
          
          div(style = "margin-top: 15px;",
              HTML(tbl_log),
              fit_box
          )
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
        
        # Force dependent variable to character, then explicitly recode
        dep_var <- input$log_dep
        dep_vec <- as.character(df[[dep_var]])
        dep_levels <- unique(dep_vec)
        
        # Check exactly two unique non-NA values
        if (length(dep_levels) != 2) {
          showNotification(strong(
            sprintf("More than 2 levels were detected. Please use multinomial regressios instead")), 
            type = "error")
          return(NULL)
        }
        
        # Explicitly set the "success" level as 'yes' if present, else the second value
        if ("yes" %in% dep_levels) {
          # Recode as factor, with 'no' as reference (0), 'yes' as 1
          df[[dep_var]] <- factor(df[[dep_var]], levels = c(setdiff(dep_levels, "yes"), "yes"))
        } else {
          # Use alphabetical ordering, first is reference (0), second is 1
          df[[dep_var]] <- factor(df[[dep_var]], levels = sort(dep_levels))
        }
        
        # Now, convert to numeric 0/1, with 'yes' or the second level as 1
        df[[dep_var]] <- as.numeric(df[[dep_var]]) - 1
        
        # Now, for predictors: always force them to factors with explicit ordering if possible
        for (pred in input$log_indep) {
          if (is.character(df[[pred]]) || is.factor(df[[pred]])) {
            # If binary, order as (reference, alternate)
            pred_levels <- unique(as.character(df[[pred]]))
            if (length(pred_levels) == 2) {
              df[[pred]] <- factor(df[[pred]], levels = sort(pred_levels))
            } else {
              df[[pred]] <- as.factor(df[[pred]])
            }
          }
        }
        
        df
      })

      # Assumptions notes     
      output$note_title_log <- renderUI({
        req(input$log_check)
        fluidRow(
          column(
            12,
            div(
              style = "display: flex; align-items: center; margin-bottom: 12px; margin-top: 12px;",
              h4(strong("Tips"), style = "margin: 0;"),
              tags$span(
                icon("info-circle", class = "fa-solid"),
                `data-bs-toggle` = "tooltip",
                `data-bs-placement` = "right",
                title = "Posterior Predictive Check:\n→ If predicted intervals miss the observed points, add predictors or check model specification.\n
Binned Residuals:\n→ If points fall outside error bounds, add relevant predictors, check variable coding, or include interactions.\n
Influential Observations:\n→ If points fall outside the contour lines, check for data errors. If valid, test the model with and without them and report major changes.\n
Collinearity (VIF):\n→ If VIF > 10, remove or combine correlated predictors.\n
Uniformity of Residuals:\n→ If dots deviate from the diagonal, check model fit, add predictors, or inspect for scaling issues.",
                class = "no-print",
                style = "margin-left:8px; color: black; cursor: pointer;"
              )
            )
          )
        )
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
          mod <- glm(fml, data = df, family = binomial(), method = "brglmFit")
          
          # --- Warning if assumption checks may be misleading ---
          b <- broom::tidy(mod, conf.int = TRUE)
          problem_vars <- b$term[is.na(b$conf.low) | is.na(b$conf.high) | abs(b$estimate) > 10]
          if (length(problem_vars) > 0) {
            showNotification(
              div(
                style = "background-color:#fff3cd; color:#856404; padding:14px; border:1px solid #ffeeba; border-radius:5px;",
                icon("exclamation-triangle", lib = "font-awesome"),
                strong("Model warning:"),
                tags$b(paste(problem_vars, collapse = ", ")),
                " may cause model diagnostics and assumption checks to be misleading.",
                "Review your predictors before interpreting these results."
              ),
              type = "warning", duration = 20
            )
          }
          
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
        if (length(rhs) == 0) {
          showNotification(strong("No predictors selected. Please select at least one predictor."), type = "error")
          return(NULL)
        }
        fml <- as.formula(paste(input$log_dep, "~", paste(rhs, collapse = " + ")))
        
        mod <- glm(fml, data = df, family = binomial(), method = "brglmFit")
        
        b <- broom::tidy(mod, conf.int = TRUE) %>%
          dplyr::mutate(
            group = dplyr::case_when(
              p.value < 0.05 & estimate > 0 ~ "sig_pos",
              p.value < 0.05 & estimate < 0 ~ "sig_neg",
              TRUE ~ "NS"
            )
          ) %>%
          dplyr::filter(!is.na(conf.low), !is.na(conf.high)) %>%
          dplyr::filter(term != "(Intercept)")
        
        # Warn for NA intervals or large estimates
        bad_terms <- b %>% dplyr::filter(is.na(conf.low) | is.na(conf.high) | abs(estimate) > 10)
        
        if (!mod$converged || nrow(bad_terms) > 0) {
          showNotification(
            div(
              style = "background-color:#fff3cd; color:#856404; padding:14px; border:1px solid #ffeeba; border-radius:5px;",
              icon("exclamation-triangle", lib = "font-awesome"),
              strong("Model warning:"),
              if (nrow(bad_terms) > 0) {
                tagList(
                  "Results may be unreliable because ",
                  tags$b(paste(bad_terms$term, collapse = ", ")),
                  " perfectly predicts the outcome or is too rare. "
                )
              } else {
                "Model did not converge. This usually means some predictors perfectly separate the outcome or categories are highly imbalanced."
              },
              "Try removing or merging these variable(s) to resolve this."
            ),
            type = "warning", duration = 20
          )
        }
        
        if (nrow(b) == 0) {
          showNotification(strong("Effect plot could not be generated due to NA estimates or intervals."), 
                           type = "error")
          return(NULL)
        }
        
        xlim_val <- max(abs(c(b$conf.low, b$conf.high)), na.rm = TRUE)
        
        ggplot2::ggplot(b, aes(x = estimate, y = term)) +
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
      

      # ---- Logistic Regression: Auto-switch to Forest Plot Tab ----
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
        updateTabsetPanel(session, inputId = "log_tabs", selected = "Forest Plot")
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

      # ---- Logistic Regression: Download Forest Plot ----
      output$log_download_effect <- downloadHandler(
        filename = function() paste0("logistic_forest_plot_", Sys.Date(), ".png"),
        content = function(file) {
          df <- log_model_data()
          main_effects <- input$log_indep
          interaction_terms <- NULL
          if (!is.null(input$log_interact) && length(input$log_interact) > 0) {
            interaction_terms <- gsub(":", " * ", input$log_interact)
          }
          rhs <- c(main_effects, interaction_terms)
          fml <- as.formula(paste(input$log_dep, "~", paste(rhs, collapse = " + ")))
          mod <- glm(fml, data = df, family = binomial(), method = "brglmFit")

          b <- broom::tidy(mod, conf.int = TRUE) %>%
            dplyr::filter(!is.na(conf.low), !is.na(conf.high), !is.na(estimate)) %>%
            dplyr::mutate(group = dplyr::case_when(
              p.value < 0.05 & estimate > 0 ~ "sig_pos",
              p.value < 0.05 & estimate < 0 ~ "sig_neg",
              TRUE ~ "NS"
            )) %>%
            dplyr::filter(!is.na(conf.low), !is.na(conf.high)) %>%
            dplyr::filter(term != "(Intercept)")

          xlim_val <- max(abs(c(b$conf.low, b$conf.high)), na.rm = TRUE)

          p <- ggplot2::ggplot(b, aes(x = estimate, y = term)) +
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
        readr::read_csv(input$nb_file$datapath, show_col_types = F) %>%
          dplyr::select(
            -dplyr::contains("infant_id", ignore.case = TRUE),
            -dplyr::contains("infantid", ignore.case = TRUE),
            -dplyr::contains("sample_id", ignore.case = TRUE),
            -dplyr::contains("sampleid", ignore.case = TRUE),
            -dplyr::contains("sample", ignore.case = TRUE),
            -dplyr::contains("accession", ignore.case = TRUE),
            -dplyr::contains("name", ignore.case = TRUE)
          )
      })

      
      # ---- Negative Binomial: UI for Dependent Variable ----
      output$nb_dep_ui <- renderUI({
        df <- nb_data()
        count_like_vars <- names(df)[sapply(df, function(col) {
          is.numeric(col) && all(col >= 0, na.rm = TRUE) && all(col == floor(col), na.rm = TRUE) &&
            length(unique(col[!is.na(col)])) > 5    ## added: must have >5 unique values
        })]

        tagList(
          selectInput("nb_dep", 
                      tagList(
                        "Select dependent variable (counts only):",
                        tags$span(
                          icon("info-circle", class = "fa-solid"),
                          `data-bs-toggle` = "tooltip",
                          `data-bs-placement` = "right",
                          title = "Note: Only count data are shown. Continuous variables are excluded, as they violate model assumptions. For continuous outcomes, please use LM or LMM instead."
                        )),
                      choices = c("Select variable" = "", count_like_vars),
                      selected = ""),
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
          "nb_interact", "Add interaction term(s) (optional):",
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

        output$nb_result <- renderUI({
          df <- nb_model_data()
          validate(need(!is.null(df), ""))
          main_effects <- input$nb_indep
          interaction_terms <- NULL

          if (!is.null(input$nb_interact) && length(input$nb_interact) > 0) {
            interaction_terms <- gsub(":", " * ", input$nb_interact)  # "A:B" becomes "A * B"
          }

          rhs <- c(main_effects, interaction_terms)
          fml <- as.formula(paste(input$nb_dep, "~", paste(rhs, collapse = " + ")))
          
          # Fit model and keep object for metrics/UI
          mod <- tryCatch(MASS::glm.nb(fml, data = df), error = function(e) NULL)
          validate(need(!is.null(mod), "Model failed to fit.")) 
          
          # Coefficient table
          b <- broom::tidy(mod, conf.int = TRUE)

        tbl_nb <- b %>% 
            dplyr::mutate(Sig = dplyr::case_when(
              is.na(p.value) ~ "",
              p.value < 0.001 ~ "***",
              p.value < 0.01 ~ "**",
              p.value < 0.05 ~ "*",
              TRUE ~ "NS"
            )) %>%
            knitr::kable(align = "c", format = "html") %>% 
          kableExtra::kable_styling(
            bootstrap_options = c("hover", "condensed", "bordered"),
            position = "center", full_width = T) %>% 
          kableExtra::scroll_box(width = "100%", height = "100%")
        
        # ---- FIT METRICS (Negative Binomial) ----
        aic          <- AIC(mod)                                                 
        bic          <- BIC(mod)                                                 
        logLik_val   <- as.numeric(logLik(mod))                                     
        
        # Optional McFadden R² (null vs full)
        ll_null        <- as.numeric(logLik(update(mod, . ~ 1)))                     
        #R2_McFadden_nb <- 1 - (logLik_val / ll_null)                                  
        
        
        # Fit box UI
        fit_box <- div(                                                       
          style = "margin-top: 14px; background:#f5f7fb; border:1px solid #d9e1f2; border-radius:8px; padding:12px;",
          div(
            style = "display:flex; align-items:center; gap:8px; margin-bottom:8px;",
            tags$strong("Model fit & what to do"),
            tags$span(
              icon("info-circle", class = "fa-solid"),
              `data-bs-toggle` = "tooltip",
              `data-bs-placement` = "right",
              title = "Akaike Information Criterion (AIC)
              Bayesian Information Criterion (BIC)
              Log-likelihood (logLik)\n\n
              Compare models fitted on the same data:\n
              • Lower AIC and BIC = better fit.
              • Higher logLik = better fit.\n
            If AIC differs by less than 2, the models fit equally well, prefer the simpler model.",
              class = "no-print",
              style = "color:black; cursor:pointer;"
            )
          ),
          tags$div(
            style = "display:grid; grid-template-columns: repeat(6, minmax(0,1fr)); gap:8px; font-size:0.95em;",
            tags$div(tags$strong("AIC"),        br(), sprintf("%.2f", aic)),
            tags$div(tags$strong("BIC"),        br(), sprintf("%.2f", bic)),
            tags$div(tags$strong("logLik"),     br(), sprintf("%.2f", logLik_val))
            #tags$div(tags$strong("McFadden R²"),br(), sprintf("%.3f", R2_McFadden_nb))
          )
        )
        div(style = "margin-top: 15px;",
            HTML(tbl_nb),
            fit_box
        )
        
        })
      })

      # Assumptions notes
      output$note_title_nb <- renderUI({
        req(input$nb_check)
        fluidRow(
          column(
            12,
            div(
              style = "display: flex; align-items: center; margin-bottom: 12px; margin-top: 12px;",
              h4(strong("Tips"), style = "margin: 0;"),
              tags$span(
                icon("info-circle", class = "fa-solid"),
                `data-bs-toggle` = "tooltip",
                `data-bs-placement` = "right",
                title = "Posterior Predictive Check:\n→ If predicted intervals do not include observed points, the model may be misspecified. Add relevant predictors or interaction terms.\n
Misspecified Dispersion or Zero-Inflation:\n→ If observed residual variance (green) does not follow predicted variance (blue), add relevant predictors, add interaction terms, or use a zero-inflated negative binomial model (if excess zeros are present).\n
Homogeneity of Variance:\n→ If the trend is not flat, transform predictors or check for missing variables.\n
Influential Observations:\n→ If points fall outside the contour lines, check for data errors. If valid, rerun the model with and without them and report major differences.\n
Collinearity:\n→ If VIF > 10, remove or combine correlated predictors.\n
Uniformity of Residuals:\n→ If dots deviate from the diagonal, reconsider model fit or add relevant predictors.",
                class = "no-print",
                style = "margin-left:8px; color: black; cursor: pointer;"
              )
            )
          )
        )
      })
      
      # ---- Zero-inflation check ----
      # Helper for null coalescing (add to your script if not present)
      `%||%` <- function(a, b) if (!is.null(a)) a else b
      
      output$nb_zeroinfl_ui <- renderUI({
        req(input$nb_check)
        df <- nb_model_data()
        main_effects <- input$nb_indep
        interaction_terms <- NULL
        if (!is.null(input$nb_interact) && length(input$nb_interact) > 0) {
          interaction_terms <- gsub(":", " * ", input$nb_interact)
        }
        rhs <- c(main_effects, interaction_terms)
        fml <- as.formula(paste(input$nb_dep, "~", paste(rhs, collapse = " + ")))
        mod <- MASS::glm.nb(fml, data = df)
        val <- performance::check_zeroinflation(mod)
        
        # Compose the UI
        ui_list <- list(
          div(
            style = "display: flex; align-items: center; margin-bottom: 12px; margin-top: 10px;",
            h4(strong("Zero-Inflation Test"), style = "margin: 0;"),
            tags$span(
              icon("info-circle", class = "fa-solid"),
              `data-bs-toggle` = "tooltip",
              `data-bs-placement` = "right",
              title = paste(
                "A formal zero-inflation test is provided because diagnostic plots can sometimes be unclear.",
                "This test gives an objective answer about zero inflation.",
                "If zero inflation is detected (i.e., ratio of observed/predicted zeros is outside 0.90–1.10), please use a zero-inflated negative binomial regression instead."
              ),
              class = "no-print",
              style = "margin-left:8px; color: black; cursor: pointer;"
            )
          )
        )
        
        # Compose details/info box and status
        if (is.null(val)) {
          ui_list <- append(ui_list, list(
            div(
              style = "background-color:#F5F5F5; color:black; font-size:1.1em; border:1.5px solid #B3B3B3; border-radius:8px; padding:12px 16px; margin-bottom:8px; white-space:pre-wrap; margin-top:12px;",
              "Model has no observed zeros in the response variable."
            )
          ))
        } else {
          # Try all common variants for the stats
          obs_zeros <- val$observed_zeros %||% val$Observed_zeros %||% val$observed %||% val$Observed %||% "NA"
          pred_zeros <- val$predicted_zeros %||% val$Predicted_zeros %||% val$predicted %||% val$Predicted %||% "NA"
          ratio <- val$ratio %||% val$Ratio %||% NA
          pval <- val$p_value %||% val$p.value %||% val$P_value %||% NA
          
          detail_text <- paste0(
            "<b>Observed zeros:</b> ", obs_zeros, "<br>",
            "<b>Predicted zeros:</b> ", pred_zeros, "<br>",
            "<b>Ratio:</b> ", if (!is.na(ratio)) sprintf("%.2f", as.numeric(ratio)) else "NA",
            if (!is.na(pval)) paste0("<br><b>p-value:</b> ", format.pval(pval, digits = 3)) else ""
          )
          
          # Use BOTH the range and the p-value for the decision (0.90–1.10)
          in_range <- (!is.na(ratio) && ratio >= 0.90 && ratio <= 1.10)
          color_box <- if (in_range) "green" else "#B20D00"
          status_msg <- if (in_range) "No evidence of zero inflation." else "Zero inflation detected."
          
          ui_list <- append(ui_list, list(
            div(
              style = "background-color:#F5F5F5; color:black; font-size:1.07em; border:1.5px solid #B3B3B3; border-radius:8px; padding:12px 16px; margin-bottom:8px; white-space:pre-line; margin-top:12px;",
              HTML(detail_text)
            ),
            div(
              style = paste0(
                "background-color:", color_box,
                "; color: white; padding: 6px 12px; border-radius: 8px; font-size: 1.12em; font-weight: bold; margin-bottom: 8px; margin-top:10px;"
              ),
              status_msg
            )
          ))
        }
        
        tagList(ui_list)
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

      # ---- Negative Binomial: Render Forest Plot (Manual) ----
      
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
        updateTabsetPanel(session, inputId = "nb_tabs", selected = "Forest Plot")
        
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
            dplyr::filter(term != "(Intercept)")
          
          ggplot2::ggplot(b, aes(x = estimate, y = term)) +
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
      

      # ---- Negative Binomial: Download Forest Plot ----
      output$nb_download_effect <- downloadHandler(
        filename = function() paste0("neg_binom_forest_plot_", Sys.Date(), ".png"),
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
            dplyr::filter(term != "(Intercept)")

          p <- ggplot2::ggplot(b, aes(x = estimate, y = term)) +
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
        
        df <- readr::read_csv(input$multi_file$datapath, show_col_types = FALSE) %>%
          dplyr::select(
            -dplyr::contains("infant_id", ignore.case = TRUE),
            -dplyr::contains("infantid", ignore.case = TRUE),
            -dplyr::contains("sample_id", ignore.case = TRUE),
            -dplyr::contains("sampleid", ignore.case = TRUE),
            -dplyr::contains("sample", ignore.case = TRUE),
            -dplyr::contains("accession", ignore.case = TRUE),
            -dplyr::contains("name", ignore.case = TRUE)
          )
        
        ## added: convert character/logical/numeric-coded categoricals to factors
        df[] <- lapply(df, function(col) {
          if (is.character(col)) {
            factor(col)
          } else if (is.logical(col)) {
            factor(col)
          } else if (is.numeric(col) &&
                     all(col == floor(col), na.rm = TRUE) &&
                     length(unique(col)) <= 15) {
            factor(as.character(col))   ## numeric-coded categorical → factor
          } else {
            col
          }
        })
        
        df
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
          "multi_interact", "Add interaction term(s) (optional):",
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

        output$multi_result <- renderUI({
          df <- multi_model_data()
          validate(need(!is.null(df), ""))
          
          main_effects <- input$multi_indep
          interaction_terms <- NULL

          if (!is.null(input$multi_interact) && length(input$multi_interact) > 0) {
            interaction_terms <- gsub(":", " * ", input$multi_interact)  # "A:B" -> "A * B"
          }

          rhs <- c(main_effects, interaction_terms)
          fml <- as.formula(paste(input$multi_dep, "~", paste(rhs, collapse = " + ")))
          #mod <- nnet::multinom(fml, data = df, trace = FALSE)
          
          # FIT MODEL (guard) -------------------------------------------------------
          res <- tryCatch({                                         
            mod <- nnet::multinom(fml, data = df, trace = FALSE)
            broom::tidy(mod, conf.int = TRUE)
          }, error = function(e) NULL)
          validate(need(!is.null(res), ""))      ## added: suppress error UI

          # Tidy table --------------------------------------------------------------
          b <- broom::tidy(mod, conf.int = TRUE)
          tbl_mul <- b %>%
            dplyr::mutate(Sig = dplyr::case_when(
              is.na(p.value) ~ "",
              p.value < 0.001 ~ "***",
              p.value < 0.01 ~ "**",
              p.value < 0.05 ~ "*",
              TRUE ~ "NS"
            )) %>%
            knitr::kable(align = "c", format = "html") %>% 
          kableExtra::kable_styling(
            bootstrap_options = c("hover", "condensed", "bordered"),
            position = "center", full_width = T) %>% 
          kableExtra::scroll_box(width = "100%", height = "100%")
          
          
          # METRICS (essential only) -----------------------------------------------
          aic        <- AIC(mod)                                                    
          bic        <- BIC(mod)                                                    
          ll_full    <- as.numeric(logLik(mod))                                    
          
          # Multiclass LogLoss (cross-entropy)                                      
          pmat <- predict(mod, type = "probs")
          y    <- df[[input$multi_dep]]
          y    <- factor(y)  # ensure factor
          # align columns of p with levels of y
          if (!is.null(colnames(pmat))) {
            miss <- setdiff(levels(y), colnames(pmat))
            if (length(miss) > 0) {
              # add missing columns with tiny probs if baseline omitted
              add <- matrix(1e-15, nrow = nrow(pmat), ncol = length(miss),
                            dimnames = list(NULL, miss))
              pmat <- cbind(pmat, add)
            }
            pmat <- pmat[, levels(y), drop = FALSE]
          }
          idx <- cbind(seq_len(nrow(df)), as.integer(y))
          eps <- 1e-15
          logloss <- -mean(log(pmax(pmat[idx], eps)))                               
          
          # FIT BOX UI --------------------------------------------------------------
          fit_box <- div(                                                           
            style = "margin-top: 14px; background:#f5f7fb; border:1px solid #d9e1f2; border-radius:8px; padding:12px;",
            div(
              style = "display:flex; align-items:center; gap:8px; margin-bottom:8px;",
              tags$strong("Model fit & what to do"),
              tags$span(
                icon("info-circle", class = "fa-solid"),
                `data-bs-toggle` = "tooltip",
                `data-bs-placement` = "right",
                title =
                  "AIC (Akaike Information Criterion)
                  BIC (Bayesian Information Criterion)
                  logLik (log-likelihood)\n\n
                  Compare models fitted on the same data:\n
                  • Lower AIC and BIC = better fit.
                  • Higher logLik = better fit\n
                If AIC differs by less than 2, the models fit equally well, prefer the simpler model.",
                class = "no-print",
                style = "color:black; cursor:pointer;"
              )
            ),
            tags$div(
              style = "display:grid; grid-template-columns: repeat(5, minmax(0,1fr)); gap:8px; font-size:0.95em;",
              tags$div(tags$strong("AIC"),    br(), sprintf("%.2f", aic)),
              tags$div(tags$strong("BIC"),    br(), sprintf("%.2f", bic)),
              tags$div(tags$strong("logLik"), br(), sprintf("%.2f", ll_full)),
            )
          )
          
          
        div(style = "margin-top: 15px;",
            HTML(tbl_mul),
            fit_box
        )
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

      
      # Assumptions notes     
      output$note_title_mult <- renderUI({
        req(input$multi_check)
        fluidRow(
          column(
            12,
            div(
              style = "display: flex; align-items: center; margin-bottom: 12px; margin-top: 12px;",
              h4(strong("Tips"), style = "margin: 0;"),
              tags$span(
                icon("info-circle", class = "fa-solid"),
                `data-bs-toggle` = "tooltip",
                `data-bs-placement` = "right",
                title = "• If many residual points fall outside the error bounds, add relevant predictors or interaction terms.\n
                • If the residual Q-Q plot deviates strongly from the diagonal, reconsider model fit or add relevant predictors.\n
                • If VIF > 10, remove or combine correlated predictors.",
                class = "no-print",
                style = "margin-left:8px; color: black; cursor: pointer;"
              )
            )
          )
        )
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
          validate(need(!is.null(df), ""))
          
          main_effects <- input$multi_indep
          interaction_terms <- NULL
          
          if (!is.null(input$multi_interact) && length(input$multi_interact) > 0) {
            interaction_terms <- gsub(":", " * ", input$multi_interact)
          }
          
          rhs <- c(main_effects, interaction_terms)
          fml <- as.formula(paste(input$multi_dep, "~", paste(rhs, collapse = " + ")))
          ok <- tryCatch({                                         ## added
            mod <- nnet::multinom(fml, data = df, trace = FALSE)
            print(performance::check_model(mod, residual_type = "normal"))
            TRUE
          }, error = function(e) FALSE)
          validate(need(ok, ""))
        })
      })

      # ---- Multinomial Regression: Download Assumption Plot ----
      output$multi_download_assump <- downloadHandler(
        filename = function() paste0("multinomial_assumption_plot_", Sys.Date(), ".pdf"),
        content = function(file) {
          df <- multi_model_data()
          if (is.null(df)) return(invisible(NULL))
          
          main_effects <- input$multi_indep
          interaction_terms <- NULL

          if (!is.null(input$multi_interact) && length(input$multi_interact) > 0) {
            interaction_terms <- gsub(":", " * ", input$multi_interact)
          }

          rhs <- c(main_effects, interaction_terms)
          fml <- as.formula(paste(input$multi_dep, "~", paste(rhs, collapse = " + ")))
          mod <- tryCatch({                                         ## added
            nnet::multinom(fml, data = df, trace = FALSE)
          }, error = function(e) NULL)
          if (is.null(mod)) return(invisible(NULL))

          check_plot <- performance::check_model(mod)

          pdf(file, width = 12, height = 9)
          print(check_plot)
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
      
      ### ---------- Poisson regression -----------####
      
      # ---- Poisson: Reactive Data Upload ----
      poiss_data <- reactive({
        req(input$poiss_file)
        readr::read_csv(input$poiss_file$datapath, show_col_types = F) %>%
          dplyr::select(
            -dplyr::contains("infant_id", ignore.case = TRUE),
            -dplyr::contains("infantid", ignore.case = TRUE),
            -dplyr::contains("sample_id", ignore.case = TRUE),
            -dplyr::contains("sampleid", ignore.case = TRUE),
            -dplyr::contains("sample", ignore.case = TRUE),
            -dplyr::contains("accession", ignore.case = TRUE),
            -dplyr::contains("name", ignore.case = TRUE)
          )
      })
      
      
      # ---- Poisson: UI for Dependent Variable ----
      output$poiss_dep_ui <- renderUI({
        df <- poiss_data()
        count_like_vars <- names(df)[sapply(df, function(col) {
          is.numeric(col) && all(col >= 0, na.rm = TRUE) && all(col == floor(col), na.rm = TRUE) &&
            length(unique(col[!is.na(col)])) > 5    ## added: must have >5 unique values
        })]
        
        tagList(
          selectInput("poiss_dep", 
                      tagList(
                        "Select dependent variable (counts only):",
                        tags$span(
                          icon("info-circle", class = "fa-solid"),
                          `data-bs-toggle` = "tooltip",
                          `data-bs-placement` = "right",
                          title = "Note: Only count data are shown. Continuous variables are excluded, as they violate model assumptions. For continuous outcomes, please use LM or LMM instead."
                        )
                      ),
                      choices = c("Select variable" = "", count_like_vars),
                      selected = ""
          )
        )
      })
      
      # ---- Poisson: UI for Independent Variables ----
      output$poiss_indep_ui <- renderUI({
        df <- poiss_data()
        all_vars <- names(df)
        choices <- setdiff(all_vars, input$poiss_dep)
        
        selectizeInput(
          "poiss_indep",
          "Select independent variables:",
          choices = choices,
          multiple = TRUE,
          selected = NULL,
          options = list(placeholder = "Select variable")
        )
      })
      
      # ---- Poisson: UI for Interactions ----
      output$poiss_interact_ui <- renderUI({
        req(input$poiss_indep)
        if (length(input$poiss_indep) < 2) return(NULL)
        
        combos <- combn(input$poiss_indep, 2, simplify = FALSE)
        interact_labels <- sapply(combos, function(x) paste(x, collapse = " : "))
        
        selectizeInput(
          "poiss_interact", "Add interaction term(s) (optional):",
          choices = setNames(sapply(combos, paste, collapse = ":"), interact_labels),
          multiple = TRUE, selected = NULL,
          options = list(placeholder = "Select interaction(s)")
        )
      })
      
      
      # ---- Poisson: Reactive for Final Model Data ----
      poiss_model_data <- reactive({
        req(poiss_data(), input$poiss_dep, input$poiss_indep)
        df <- poiss_data()
        model_vars <- c(input$poiss_dep, input$poiss_indep)
        
        df <- df %>%
          dplyr::select(all_of(model_vars)) %>%
          tidyr::drop_na()
        
        if (input$poiss_dep %in% input$poiss_indep) {
          showNotification(strong("Dependent variable cannot be included as independent."), type = "error")
          return(NULL)
        }
        
        if (length(input$poiss_indep) < 1) {
          showNotification(strong("Please select at least one independent variable."), type = "error")
          return(NULL)
        }
        
        df
      })
      
      # ---- Poisson: Run Model and Show Result Table ----
      observeEvent(input$poiss_run, {
        if (is.null(input$poiss_file)) {
          showNotification(strong("Please upload a data file."), type = "error")
          return()
        }
        if (is.null(input$poiss_dep) || input$poiss_dep == "") {
          showNotification(strong("Please choose dependent variable."), type = "error")
          return()
        }
        if (is.null(input$poiss_indep) || length(input$poiss_indep) < 1) {
          showNotification(strong("Please choose independent variable(s)."), type = "error")
          return()
        }
        req(poiss_model_data())
        updateTabsetPanel(session, inputId = "poiss_tabs", selected = "Test Result")
        
        output$poiss_result <- renderUI({
          df <- poiss_model_data()
          main_effects <- input$poiss_indep
          interaction_terms <- NULL
          
          if (!is.null(input$poiss_interact) && length(input$poiss_interact) > 0) {
            interaction_terms <- gsub(":", " * ", input$poiss_interact)  # "A:B" becomes "A * B"
          }
          
          rhs <- c(main_effects, interaction_terms)
          fml <- as.formula(paste(input$poiss_dep, "~", paste(rhs, collapse = " + ")))
          
          # fit model and keep object for metrics/UI
          mod <- tryCatch(glm(fml, data = df, family = poisson), error = function(e) NULL)  
          validate(need(!is.null(mod), "Model failed to fit.")) 
          
          
          tbl_poiss <- broom::tidy(mod, conf.int = TRUE) %>%
            dplyr::mutate(Sig = dplyr::case_when(
              is.na(p.value) ~ "",
              p.value < 0.001 ~ "***",
              p.value < 0.01 ~ "**",
              p.value < 0.05 ~ "*",
              TRUE ~ "NS"
            )) %>%
            knitr::kable(align = "c", format = "html") %>%
            kableExtra::kable_styling(
              bootstrap_options = c("hover", "condensed", "bordered"),
              position = "center", full_width = T
            ) %>%
            kableExtra::scroll_box(width = "100%", height = "100%")
          
          # INSERTED: essential metrics for comparing 2 Poisson models
          aic        <- AIC(mod)                                  # INSERTED
          bic        <- BIC(mod)                                  # INSERTED
          ll_full    <- as.numeric(logLik(mod))                   # INSERTED
          dispersion <- mod$deviance / mod$df.residual            # INSERTED
          
          # INSERTED: compact fit box (same template as your other models)
          fit_box <- div(
            style = "margin-top: 14px; background:#f5f7fb; border:1px solid #d9e1f2; border-radius:8px; padding:12px;",
            div(
              style = "display:flex; align-items:center; gap:8px; margin-bottom:8px;",
              tags$strong("Model fit & what to do"),
              tags$span(
                icon("info-circle", class = "fa-solid"),
                `data-bs-toggle` = "tooltip",
                `data-bs-placement` = "right",
                title ="AIC (Akaike Information Criterion)
                BIC (Bayesian Information Criterion)
                logLik (log-likelihood)\n\n
                Compare models fitted on the same data:\n
                • Lower AIC and BIC = better fit.
                • Higher logLik = better fit.
                • Dispersion close to 1 is expected for Poisson; large values suggest overdispersion.\n
                If AIC differs by < 2, the models fit equally well, prefer the simpler model.",
                class = "no-print",
                style = "color:black; cursor:pointer;"
              )
            ),
            tags$div(
              style = "display:grid; grid-template-columns: repeat(6, minmax(0,1fr)); gap:8px; font-size:0.95em;",
              tags$div(tags$strong("AIC"),        br(), sprintf("%.2f", aic)),
              tags$div(tags$strong("BIC"),        br(), sprintf("%.2f", bic)),
              tags$div(tags$strong("logLik"),     br(), sprintf("%.2f", ll_full)),
              tags$div(tags$strong("Dispersion"), br(), sprintf("%.2f", dispersion))
            )
          )
          
          
          div(style = "margin-top: 15px;",
              HTML(tbl_poiss),
              fit_box
          )
        })
      })
      
      
      
      # ---- Poisson: Overdispersion Test Value ----
      poiss_overdisp_val <- reactive({
        req(poiss_model_data(), input$poiss_dep, input$poiss_indep)
        df <- poiss_model_data()
        main_effects <- input$poiss_indep
        interaction_terms <- NULL
        
        if (!is.null(input$poiss_interact) && length(input$poiss_interact) > 0) {
          interaction_terms <- gsub(":", " * ", input$poiss_interact)
        }
        
        rhs <- c(main_effects, interaction_terms)
        fml <- as.formula(paste(input$poiss_dep, "~", paste(rhs, collapse = " + ")))
        mod <- glm(fml, data = df, family = poisson)
        result <- performance::check_overdispersion(mod)
        as.list(result)
      })
      
      
      # Overdispersion Box/Status
      output$poiss_overdisp_ui <- renderUI({
        req(input$poiss_check)
        val <- poiss_overdisp_val()
        
        test_result <- div(
          style = "background-color:#F5F5F5; color:black; font-size:1em;
       border:1.5px solid #B3B3B3; border-radius:8px; padding:14px 18px; margin-bottom:8px; white-space:pre-wrap;",
          paste(capture.output(print(val)), collapse = "\n")
        )
        
        pval <- NA
        if (!is.null(val) && !is.null(val$p_value) && length(val$p_value) > 0) {
          pval <- as.numeric(val$p_value)
        }
        is_overdisp <- !is.na(pval) && pval < 0.05
        
        color_box <- if (is_overdisp) "#B20D00" else "green"
        status_msg <- if (is_overdisp) "Overdispersion detected." else "No evidence of overdispersion."
        
        status_box <- div(
          style = paste0(
            "background-color:", color_box,
            "; color: white; padding: 6px 12px; border-radius: 5px; font-size: 1em; font-weight: bold; margin-bottom: 8px;"
          ),
          status_msg
        )
        
        tagList(
          div(
            style = "display: flex; align-items: center; margin-bottom: 12px; margin-top: 10px;",
            h4(strong("Overdispersion Test"), style = "margin: 0;"),
            tags$span(
              icon("info-circle", class = "fa-solid"),
              `data-bs-toggle` = "tooltip",
              `data-bs-placement` = "right",
              title = "A formal overdispersion test is provided because, in some cases, diagnostic plots can be ambiguous or not fully clear. This statistical test gives an objective decision about overdispersion, even when the plot is hard to interpret. If overdispersion is detected, please use negative binomial regression instead",
              class = "no-print",
              style = "margin-left:8px; color: black; cursor: pointer;"
            )
          ),
          test_result,
          status_box,
          br()
        )
        
        
      })
      
      
      
      
      
      
      
      # ---- Poisson: Diagnostic Plot ----
      observeEvent(input$poiss_check, {
        if (is.null(input$poiss_file)) {
          showNotification(strong("Please upload a data file."), type = "error")
          return()
        }
        if (is.null(input$poiss_dep) || input$poiss_dep == "") {
          showNotification(strong("Please choose dependent variable."), type = "error")
          return()
        }
        if (is.null(input$poiss_indep) || length(input$poiss_indep) < 1) {
          showNotification(strong("Please choose independent variable(s)."), type = "error")
          return()
        }
        req(poiss_model_data())
        updateTabsetPanel(session, inputId = "poiss_tabs", selected = "Assumptions")
        
        output$poiss_assump <- renderPlot({
          df <- poiss_model_data()
          main_effects <- input$poiss_indep
          interaction_terms <- NULL
          
          if (!is.null(input$poiss_interact) && length(input$poiss_interact) > 0) {
            interaction_terms <- gsub(":", " * ", input$poiss_interact)
          }
          
          rhs <- c(main_effects, interaction_terms)
          fml <- as.formula(paste(input$poiss_dep, "~", paste(rhs, collapse = " + ")))
          
          mod <- glm(fml, data = df, family = poisson)
          performance::check_model(mod)
        })
      })
      
      # (Assumptions Tips)
      output$note_title_poiss <- renderUI({
        req(input$poiss_check)
        fluidRow(
          column(
            12,
            div(
              style = "display: flex; align-items: center; margin-bottom: 12px; margin-top: 12px;",
              h4(strong("Tips"), style = "margin: 0;"),
              tags$span(
                icon("info-circle", class = "fa-solid"),
                `data-bs-toggle` = "tooltip",
                `data-bs-placement` = "right",
                title = "Posterior Predictive Check:\n→ If predicted intervals do not include observed points, the model may be misspecified. Add predictors or consider a different count model.\n
Misspecified Dispersion or Zero-Inflation:\n→ If the green line is much higher, there is overdispersion. Consider a negative binomial, or zero-inflated model (if needed).\n
Homogeneity of Variance:\n→ If the trend is not flat, transform predictors or use a negative binomial model.\n
Influential Observations:\n→ If points fall outside the contour lines, check for data errors. If valid, rerun the model with and without them and report major differences.\n
Collinearity (VIF):\n→ If VIF > 10, remove or combine correlated predictors.\n
Uniformity of Residuals:\n→ If dots deviate from the diagonal, check model fit or consider a negative binomial model.",
                class = "no-print",
                style = "margin-left:8px; color: black; cursor: pointer;"
              )
            )
          )
        )
      })
      
      # Download assumptions plot
      output$poiss_download_assump <- downloadHandler(
        filename = function() paste0("poisson_assumption_plot_", Sys.Date(), ".pdf"),
        content = function(file) {
          df <- poiss_model_data()
          main_effects <- input$poiss_indep
          interaction_terms <- NULL
          
          if (!is.null(input$poiss_interact) && length(input$poiss_interact) > 0) {
            interaction_terms <- gsub(":", " * ", input$poiss_interact)
          }
          
          rhs <- c(main_effects, interaction_terms)
          fml <- as.formula(paste(input$poiss_dep, "~", paste(rhs, collapse = " + ")))
          mod <- glm(fml, data = df, family = poisson)
          
          p <- performance::check_model(mod)
          
          pdf(file, width = 13, height = 11)
          print(p)
          dev.off()
        },
        contentType = "application/pdf"
      )
      
      # Forest plot
      observeEvent(input$poiss_plot, {
        if (is.null(input$poiss_file)) {
          showNotification(strong("Please upload a data file."), type = "error")
          return()
        }
        if (is.null(input$poiss_dep) || input$poiss_dep == "") {
          showNotification(strong("Please choose dependent variable."), type = "error")
          return()
        }
        if (is.null(input$poiss_indep) || length(input$poiss_indep) < 1) {
          showNotification(strong("Please choose independent variable(s)."), type = "error")
          return()
        }
        req(poiss_model_data())
        updateTabsetPanel(session, inputId = "poiss_tabs", selected = "Forest Plot")
        
        output$poiss_effect <- renderPlot({
          df <- poiss_model_data()
          main_effects <- input$poiss_indep
          interaction_terms <- NULL
          
          if (!is.null(input$poiss_interact) && length(input$poiss_interact) > 0) {
            interaction_terms <- gsub(":", " * ", input$poiss_interact)
          }
          
          rhs <- c(main_effects, interaction_terms)
          fml <- as.formula(paste(input$poiss_dep, "~", paste(rhs, collapse = " + ")))
          mod <- glm(fml, data = df, family = poisson)
          
          
          
          b <- broom::tidy(mod, conf.int = TRUE) %>%
            dplyr::filter(!is.na(conf.low), !is.na(conf.high), !is.na(estimate)) %>%
            dplyr::mutate(group = dplyr::case_when(
              p.value < 0.05 & estimate > 0 ~ "sig_pos",
              p.value < 0.05 & estimate < 0 ~ "sig_neg",
              TRUE ~ "NS"
            )) %>%
            dplyr::filter(!is.na(conf.low), !is.na(conf.high)) %>%
            dplyr::filter(term != "(Intercept)")
          
          ggplot2::ggplot(b, aes(x = estimate, y = term)) +
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
      
      
      # Download forest plot
      output$poiss_download_effect <- downloadHandler(
        filename = function() paste0("poisson_forest_plot_", Sys.Date(), ".png"),
        content = function(file) {
          df <- poiss_model_data()
          main_effects <- input$poiss_indep
          interaction_terms <- NULL
          
          if (!is.null(input$poiss_interact) && length(input$poiss_interact) > 0) {
            interaction_terms <- gsub(":", " * ", input$poiss_interact)
          }
          
          rhs <- c(main_effects, interaction_terms)
          fml <- as.formula(paste(input$poiss_dep, "~", paste(rhs, collapse = " + ")))
          mod <- glm(fml, data = df, family = poisson)
          
          b <- broom::tidy(mod, conf.int = TRUE) %>%
            dplyr::filter(!is.na(conf.low), !is.na(conf.high), !is.na(estimate)) %>%
            dplyr::mutate(group = dplyr::case_when(
              p.value < 0.05 & estimate > 0 ~ "sig_pos",
              p.value < 0.05 & estimate < 0 ~ "sig_neg",
              TRUE ~ "NS"
            )) %>%
            dplyr::filter(!is.na(conf.low), !is.na(conf.high)) %>%
            dplyr::filter(term != "(Intercept)")
          
          p <- ggplot2::ggplot(b, aes(x = estimate, y = term)) +
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
      
##############################################################################################################
##############################################################################################################
##############################################################################################################
##############################################################################################################
##############################################################################################################
##############################################################################################################
##############################################################################################################
##############################################################################################################
      
      ### ---------- Zero-inflated NB regression -----------####
      
      # ---- ZINB: Reactive Data Upload ----
      zinb_data <- reactive({
        req(input$zinb_file)
        readr::read_csv(input$zinb_file$datapath, show_col_types = FALSE) %>%
          dplyr::select(
            -dplyr::contains("infant_id", ignore.case = TRUE),
            -dplyr::contains("infantid", ignore.case = TRUE),
            -dplyr::contains("sample_id", ignore.case = TRUE),
            -dplyr::contains("sampleid", ignore.case = TRUE),
            -dplyr::contains("sample", ignore.case = TRUE),
            -dplyr::contains("accession", ignore.case = TRUE),
            -dplyr::contains("name", ignore.case = TRUE)
          )
      })
      
      
      # ---- ZINB: UI for Dependent Variable ----
      output$zinb_dep_ui <- renderUI({
        df <- zinb_data()
        count_like_vars <- names(df)[sapply(df, function(col) {
          is.numeric(col) && all(col >= 0, na.rm = TRUE) && all(col == floor(col), na.rm = TRUE) &&
            length(unique(col[!is.na(col)])) > 5    ## added: must have >5 unique values
        })]
        tagList(
          selectInput("zinb_dep", 
                      tagList(
                        "Select dependent variable (counts only):",
                        tags$span(
                          icon("info-circle", class = "fa-solid"),
                          `data-bs-toggle` = "tooltip",
                          `data-bs-placement` = "right",
                          title = "Note: Only count data are shown. Continuous variables are excluded, as they violate model assumptions. For continuous outcomes, please use LM or LMM instead."
                        )),
                      choices = c("Select variable" = "", count_like_vars),
                      selected = "")
        )
      })
      
      # ---- ZINB: UI for Independent Variables ----
      output$zinb_indep_ui <- renderUI({
        df <- zinb_data()
        all_vars <- names(df)
        choices <- setdiff(all_vars, input$zinb_dep)
        selectizeInput(
          "zinb_indep",
          "Select independent variables:",
          choices = choices,
          multiple = TRUE,
          selected = NULL,
          options = list(placeholder = "Select variable")
        )
      })
      
      # ---- ZINB: UI for Interactions ----
      output$zinb_interact_ui <- renderUI({
        req(input$zinb_indep)
        if (length(input$zinb_indep) < 2) return(NULL)
        combos <- combn(input$zinb_indep, 2, simplify = FALSE)
        interact_labels <- sapply(combos, function(x) paste(x, collapse = " : "))
        selectizeInput(
          "zinb_interact", "Add interaction term(s) (optional):",
          choices = setNames(sapply(combos, paste, collapse = ":"), interact_labels),
          multiple = TRUE, selected = NULL,
          options = list(placeholder = "Select interaction(s)")
        )
      })
      
      # ---- ZINB: Reactive for Final Model Data ----
      zinb_model_data <- reactive({
        req(zinb_data(), input$zinb_dep, input$zinb_indep)
        df <- zinb_data()
        model_vars <- c(input$zinb_dep, input$zinb_indep)
        df <- df %>%
          dplyr::select(all_of(model_vars)) %>%
          tidyr::drop_na()
        
        if (input$zinb_dep %in% input$zinb_indep) {
          showNotification(strong("Dependent variable cannot be included as independent."), type = "error")
          return(NULL)
        }
        if (length(input$zinb_indep) < 1) {
          showNotification(strong("Please select at least one independent variable."), type = "error")
          return(NULL)
        }
        df
      })
      
      # ---- ZINB: Run Model and Show Result Table ----
      observeEvent(input$zinb_run, {
        if (is.null(input$zinb_file)) {
          showNotification(strong("Please upload a data file."), type = "error")
          return()
        }
        if (is.null(input$zinb_dep) || input$zinb_dep == "") {
          showNotification(strong("Please choose dependent variable."), type = "error")
          return()
        }
        if (is.null(input$zinb_indep) || length(input$zinb_indep) < 1) {
          showNotification(strong("Please choose independent variable(s)."), type = "error")
          return()
        }
        req(zinb_model_data())
        updateTabsetPanel(session, inputId = "zinb_tabs", selected = "Test Result")
        
        output$zinb_result <- renderUI({
          df <- zinb_model_data()
          main_effects <- input$zinb_indep
          interaction_terms <- NULL
          
          if (!is.null(input$zinb_interact) && length(input$zinb_interact) > 0) {
            interaction_terms <- gsub(":", " * ", input$zinb_interact)  # "A:B" becomes "A * B"
          }
          
          rhs <- c(main_effects, interaction_terms)
          fml <- as.formula(paste(input$zinb_dep, "~", paste(rhs, collapse = " + ")))
          #ziform <- as.formula(paste("~", paste(rhs, collapse = " + ")))
          
          
          mod <- tryCatch(                                                          
            glmmTMB::glmmTMB(
              formula    = fml,
              ziformula  = ~ 1,
              family     = glmmTMB::nbinom2,
              data       = df
            ),
            error = function(e) NULL
          )                                                                        
          validate(need(!is.null(mod), "Model failed to fit.")) 
          
          
          tbl_zinb <- broom.mixed::tidy(mod, conf.int = TRUE) %>%
            dplyr::mutate(Sig = dplyr::case_when(
              is.na(p.value) ~ "",
              p.value < 0.001 ~ "***",
              p.value < 0.01 ~ "**",
              p.value < 0.05 ~ "*",
              TRUE ~ "NS"
            )) %>%
            dplyr::filter(component != "zi") %>% 
            dplyr::select(- component) %>% 
            knitr::kable(align = "c", format = "html") %>%
            kableExtra::kable_styling(
              bootstrap_options = c("hover", "condensed", "bordered"),
              position = "center", full_width = TRUE
            ) %>%
            kableExtra::scroll_box(width = "100%", height = "100%")
          
          # METRICS FOR MODEL COMPARISON (minimal) -----------------------------------
          aic     <- AIC(mod)                                                        
          bic     <- BIC(mod)                                                       
          ll_full <- as.numeric(logLik(mod))                                        
          
          # Compact fit box (same template style) ------------------------------------
          fit_box <- div(                                                           
            style = "margin-top: 14px; background:#f5f7fb; border:1px solid #d9e1f2; border-radius:8px; padding:12px;",
            div(
              style = "display:flex; align-items:center; gap:8px; margin-bottom:8px;",
              tags$strong("Model fit & what to do"),
              tags$span(
                icon("info-circle", class = "fa-solid"),
                `data-bs-toggle` = "tooltip",
                `data-bs-placement` = "right",
                title ="AIC (Akaike Information Criterion)
                BIC (Bayesian Information Criterion)
                logLik (log-likelihood)\n\n
                Compare models fitted on the same data:
                • Lower AIC and BIC = better fit.
                • Higher logLik = better fit.\n
                If AIC differs by < 2, the models fit equally well, prefer the simpler model.",
                class = "no-print",
                style = "color:black; cursor:pointer;"
              )
            ),
            tags$div(
              style = "display:grid; grid-template-columns: repeat(6, minmax(0,1fr)); gap:8px; font-size:0.95em;",
              tags$div(tags$strong("AIC"),    br(), sprintf("%.2f", aic)),
              tags$div(tags$strong("BIC"),    br(), sprintf("%.2f", bic)),
              tags$div(tags$strong("logLik"), br(), sprintf("%.2f", ll_full))
            )
          )
          
          div(style = "margin-top: 15px;",
              HTML(tbl_zinb),
              fit_box
          )
        })
      })
      
      # ---- ZINB: Assumptions notes (Tips) ----
      output$note_title_zinb <- renderUI({
        req(input$zinb_check)
        fluidRow(
          column(
            12,
            div(
              style = "display: flex; align-items: center; margin-bottom: 12px; margin-top: 12px;",
              h4(strong("Tips"), style = "margin: 0;"),
              tags$span(
                icon("info-circle", class = "fa-solid"),
                `data-bs-toggle` = "tooltip",
                `data-bs-placement` = "right",
                title = "Posterior Predictive Check:\n→ If predicted intervals do not include observed points, the model may be misspecified. Add relevant predictors or interaction terms.\n
Misspecified Dispersion or Zero-Inflation:\n→ If observed residual variance (green) does not follow predicted variance (blue), add predictors or interaction terms, or include predictors that explain extra zeros.\n
Homogeneity of Variance:\n→ If the trend is not flat, transform predictors or check for missing variables.\n
Influential Observations:\n→ If points fall outside the contour lines, check for data errors. If valid, rerun the model with and without them and report major differences.\n
Collinearity:\n→ If VIF > 10, remove or combine correlated predictors.\n
Uniformity of Residuals:\n→ If dots deviate from the diagonal, reconsider model fit or add relevant predictors."
                ,
                class = "no-print",
                style = "margin-left:8px; color: black; cursor: pointer;"
              )
            )
          )
        )
      })
      
      # ---- ZINB: Diagnostic Plot ----
      observeEvent(input$zinb_check, {
        if (is.null(input$zinb_file)) {
          showNotification(strong("Please upload a data file."), type = "error")
          return()
        }
        if (is.null(input$zinb_dep) || input$zinb_dep == "") {
          showNotification(strong("Please choose dependent variable."), type = "error")
          return()
        }
        if (is.null(input$zinb_indep) || length(input$zinb_indep) < 1) {
          showNotification(strong("Please choose independent variable(s)."), type = "error")
          return()
        }
        req(zinb_model_data())
        updateTabsetPanel(session, inputId = "zinb_tabs", selected = "Assumptions")
        
        output$zinb_assump <- renderPlot({
          df <- zinb_model_data()
          main_effects <- input$zinb_indep
          interaction_terms <- NULL
          
          if (!is.null(input$zinb_interact) && length(input$zinb_interact) > 0) {
            interaction_terms <- gsub(":", " * ", input$zinb_interact)
          }
          
          rhs <- c(main_effects, interaction_terms)
          fml <- as.formula(paste(input$zinb_dep, "~", paste(rhs, collapse = " + ")))
          ziform <- as.formula(paste("~", paste(rhs, collapse = " + ")))
          
          mod <- glmmTMB::glmmTMB(
            formula = fml,
            ziformula = ~ 1,
            family = glmmTMB::nbinom2,
            data = df
          )
          performance::check_model(mod)
        })
      })
      
      # ---- ZINB: Render Forest Plot ----
      observeEvent(input$zinb_plot, {
        if (is.null(input$zinb_file)) {
          showNotification(strong("Please upload a data file."), type = "error")
          return()
        }
        if (is.null(input$zinb_dep) || input$zinb_dep == "") {
          showNotification(strong("Please choose dependent variable."), type = "error")
          return()
        }
        if (is.null(input$zinb_indep) || length(input$zinb_indep) < 1) {
          showNotification(strong("Please choose independent variable(s)."), type = "error")
          return()
        }
        req(zinb_model_data())
        updateTabsetPanel(session, inputId = "zinb_tabs", selected = "Forest Plot")
        
        output$zinb_effect <- renderPlot({
          df <- zinb_model_data()
          main_effects <- input$zinb_indep
          interaction_terms <- NULL
          
          if (!is.null(input$zinb_interact) && length(input$zinb_interact) > 0) {
            interaction_terms <- gsub(":", " * ", input$zinb_interact)
          }
          
          rhs <- c(main_effects, interaction_terms)
          fml <- as.formula(paste(input$zinb_dep, "~", paste(rhs, collapse = " + ")))
          ziform <- as.formula(paste("~", paste(rhs, collapse = " + ")))
          
          mod <- glmmTMB::glmmTMB(
            formula = fml,
            ziformula = ~ 1,
            family = glmmTMB::nbinom2,
            data = df
          )
          
          b <- broom.mixed::tidy(mod, conf.int = TRUE, effects = "fixed") %>%
            dplyr::filter(component == "cond", !is.na(conf.low), !is.na(conf.high), !is.na(estimate)) %>%
            dplyr::mutate(group = dplyr::case_when(
              p.value < 0.05 & estimate > 0 ~ "sig_pos",
              p.value < 0.05 & estimate < 0 ~ "sig_neg",
              TRUE ~ "NS"
            )) %>%
            dplyr::filter(term != "(Intercept)")
          
          ggplot2::ggplot(b, aes(x = estimate, y = term)) +
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
      
      # ---- ZINB: Download Forest Plot ----
      output$zinb_download_effect <- downloadHandler(
        filename = function() paste0("zinb_forest_plot_", Sys.Date(), ".png"),
        content = function(file) {
          df <- zinb_model_data()
          main_effects <- input$zinb_indep
          interaction_terms <- NULL
          
          if (!is.null(input$zinb_interact) && length(input$zinb_interact) > 0) {
            interaction_terms <- gsub(":", " * ", input$zinb_interact)
          }
          
          rhs <- c(main_effects, interaction_terms)
          fml <- as.formula(paste(input$zinb_dep, "~", paste(rhs, collapse = " + ")))
          ziform <- as.formula(paste("~", paste(rhs, collapse = " + ")))
          
          mod <- glmmTMB::glmmTMB(
            formula = fml,
            ziformula = ~ 1,
            family = glmmTMB::nbinom2,
            data = df
          )
          
          b <- broom.mixed::tidy(mod, conf.int = TRUE, effects = "fixed") %>%
            dplyr::filter(component == "cond", !is.na(conf.low), !is.na(conf.high), !is.na(estimate)) %>%
            dplyr::mutate(group = dplyr::case_when(
              p.value < 0.05 & estimate > 0 ~ "sig_pos",
              p.value < 0.05 & estimate < 0 ~ "sig_neg",
              TRUE ~ "NS"
            )) %>%
            dplyr::filter(term != "(Intercept)")
          
          p <- ggplot2::ggplot(b, aes(x = estimate, y = term)) +
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
      
      # ---- ZINB: Download Assumption Plot as PDF ----
      output$zinb_download_assump <- downloadHandler(
        filename = function() paste0("zinb_assumption_plot_", Sys.Date(), ".pdf"),
        content = function(file) {
          df <- zinb_model_data()
          main_effects <- input$zinb_indep
          interaction_terms <- NULL
          
          if (!is.null(input$zinb_interact) && length(input$zinb_interact) > 0) {
            interaction_terms <- gsub(":", " * ", input$zinb_interact)
          }
          
          rhs <- c(main_effects, interaction_terms)
          fml <- as.formula(paste(input$zinb_dep, "~", paste(rhs, collapse = " + ")))
          ziform <- as.formula(paste("~", paste(rhs, collapse = " + ")))
          
          mod <- glmmTMB::glmmTMB(
            formula = fml,
            ziformula = ~ 1,
            family = glmmTMB::nbinom2,
            data = df
          )
          
          p <- performance::check_model(mod)
          pdf(file, width = 13, height = 11)
          print(p)
          dev.off()
        },
        contentType = "application/pdf"
      )
      

} # end server

# ----- RUN APP -----
shinyApp(ui, server)
