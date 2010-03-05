syntax clear
syntax match pojstatusAC /Accepted/
syntax match pojstatusPE /Presentation Error/
syntax match pojstatusTLE /Time Limit Exceeded/
syntax match pojstatusMLE /Memory Limit Exceeded/
syntax match pojstatusWA /Wrong Answer/
syntax match pojstatusRE /Runtime Error/
syntax match pojstatusOLE /Output Limit Exceeded/
syntax match pojstatusCE /Compile Error/
syntax match pojstatusSE /System Error/
syntax match pojstatusVE /Validation Error/
syntax match pojstatusWT /Waiting/
highlight pojstatusAC ctermfg=Blue guifg=Blue
highlight pojstatusPE ctermfg=Red guifg=Red
highlight default link pojstatusTLE pojstatusPE
highlight default link pojstatusMLE pojstatusPE
highlight default link pojstatusWA pojstatusPE
highlight default link pojstatusRE pojstatusPE
highlight default link pojstatusOLE pojstatusPE
highlight pojstatusCE ctermfg=Green guifg=Green
highlight default link pojstatusSE pojstatusCE
highlight default link pojstatusVE pojstatusCE
highlight default link pojstatusWT pojstatusCE

