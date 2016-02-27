library(shiny)
shinyUI(fluidPage(
  titlePanel("Gene Type ParseR (Gene TyPR) | Homo Sapiens"), #
  tags$head(tags$style(type="text/css","#loadmessage {position:fixed;top:0px;left:0px;width:100%;padding:1px 0px 1px 0px;text-align:center;font-weight:bold;font-size:100%;color:#000000;background-color:#d60000;z-index:105;} #infolink {padding-bottom:10px;}")),
  conditionalPanel(condition="$('html').hasClass('shiny-busy')",tags$div("Loading...",id="loadmessage")),
  sidebarLayout(
    sidebarPanel(
      tags$div(id="info",checked=NA,tags$p("This app downloads the latest NCBI Homo sapiens gene information and displays user-selected gene type data. "),
               tags$div(id="infolink",checked=NA,tags$a(href="http://www.ncbi.nlm.nih.gov/gene/","NCBI Gene webpage",style="color:#0000FF;text-decoration:underline;"))),
      radioButtons("type","Select gene type:",c("Protein-coding"="proteincoding","Transfer RNA"="tRNA","Ribosomal RNA"="rRNA","Small nuclear RNA"="snRNA","Small nucleolar RNA"="snoRNA","Non-coding RNA"="ncRNA","Pseudogenes"="pseudo","Other"="other","Unknown"="unknown")),
      tags$div(id="info",checked=NA,tags$p(tags$b("** ",style="color:#D60000"),"For large gene numbers, the",(tags$b("Gene Details"))," tab may take a moment to load.")),
      tags$div(id="info",checked=NA,tags$p(tags$b("Download selected gene type data:"))),
      downloadButton('downloadData1','Download Gene Details'),
      downloadButton('downloadData2','Download Gene Count')
    ),
    mainPanel(
      h4("Total number of genes for selected type: "),verbatimTextOutput('totalnumbergenes'),
      tabsetPanel(type="tabs",
                  tabPanel(h4("Plot"),plotOutput("plot")),
                  tabPanel(h4("Gene Count"),dataTableOutput('summary')),
                  tabPanel(h4("Gene Details"),dataTableOutput('table'))
      )
    )
  )
))
