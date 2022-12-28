%*DEFINE (macro-name (parameter-list)) [LOCAL local-list] (macro-body)




%'Define:'
%*DEFINE (DW (LIST, LABEL))
%LABEL: DW %LIST
)

%'Call:'
%DW (%(120, 121, 122, 123, -1), TABLE)

%'Output:'
TABLE: DW 120, 121, 122, 123, -1