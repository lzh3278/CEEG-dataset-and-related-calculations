*数据预处理
import excel "/Users/AARON/Library/CloudStorage/OneDrive-个人/SEA/本科毕设-家庭水—能耦合/家电数据库处理/家电数据库/index/washmachine/年度-模型输入.xlsx", sheet("raw") firstrow
xtset Province_code Year, yearly

*描述性统计和相关系数矩阵
summarize GDP_pc_G Retail_GR Pop_GR Adult_R Urban_R WM_Sales Pulsator_lv1 Pulsator_lowelec Pulsator_lowwater Platen_lv1 Platen_lowelec Platen_lowwater, separator(0)
correlate GDP_pc_G Retail_GR Pop_GR Adult_R Urban_R WM_Sales

*单位根检验
xtunitroot llc GDPpc_G, lags(2) demean
xtunitroot fisher GDPpc_G, dfuller lags(2) demean

xtunitroot llc CPI, lags(2) demean
xtunitroot fisher CPI, dfuller lags(2) demean

xtunitroot llc Adult_R, lags(2) demean
xtunitroot fisher Adult_R, dfuller lags(2) demean

xtunitroot llc Pop_GR, lags(2) demean
xtunitroot fisher Pop_GR, dfuller lags(2) demean

xtunitroot llc Urban_R, lags(2) demean
xtunitroot fisher Urban_R, dfuller lags(2) demean

xtunitroot llc PubFC, lags(2) demean
xtunitroot fisher PubFC, dfuller lags(2) demean

xtunitroot llc HACost, lags(2) demean
xtunitroot fisher HACost, dfuller lags(2) demean

xtunitroot llc HA_Sales, lags(2) demean
xtunitroot fisher HA_Sales, dfuller lags(2) demean

xtunitroot llc Pulsator_lv1, lags(2) demean
xtunitroot fisher Pulsator_lv1, dfuller lags(2) demean

xtunitroot llc Pulsator_lowelec, lags(2) demean
xtunitroot fisher Pulsator_lowelec, dfuller lags(2) demean

xtunitroot llc Pulsator_lowwater, lags(2) demean
xtunitroot fisher Pulsator_lowwater, dfuller lags(2) demean

xtunitroot llc Platen_lv1, lags(2) demean
xtunitroot fisher Platen_lv1, dfuller lags(2) demean

xtunitroot llc Platen_lowelec, lags(2) demean
xtunitroot fisher Platen_lowelec, dfuller lags(2) demean

xtunitroot llc Platen_lowwater, lags(2) demean
xtunitroot fisher Platen_lowwater, dfuller lags(2) demean

xtunitroot llc Elecwh_lv1, lags(2) demean
xtunitroot fisher Elecwh_lv1, dfuller lags(2) demean

xtunitroot llc Gaswh_lv1, lags(2) demean
xtunitroot fisher Gaswh_lv1, dfuller lags(2) demean

xtunitroot llc DW_lowwater, lags(2) demean
xtunitroot fisher DW_lowwater, dfuller lags(2) demean

xtunitroot llc DW_lowelec, lags(2) demean
xtunitroot fisher DW_lowelec, dfuller lags(2) demean

xtunitroot llc WM_lv1, lags(2) demean
xtunitroot fisher WM_lv1, dfuller lags(2) demean

gen dPubFC = d.PubFC
gen dHA_Sales = d.HA_Sales

xtunitroot llc dPubFC, lags(1)
xtunitroot fisher dPubFC, dfuller lags(1)

xtunitroot llc dHA_Sales, lags(1) demean
xtunitroot fisher dHA_Sales, dfuller lags(1) trend

* 豪斯曼检验
xtreg WM_lv1 GDPpc_GR CPI Pop_GR Adult_R Urban_R PubFC HA_Sales c.Year_code, fe r
est store FEwm
xtreg WM_lv1 GDPpc_GR CPI Pop_GR Adult_R Urban_R PubFC HA_Sales c.Year_code, re r
est store REwm
hausman FEwm REwm

* 面板回归
xtreg WM_lv1 GDPpc_GR CPI Pop_GR Adult_R Urban_R PubFC HA_Sales c.Year_code, fe r
outreg2 using wm_fe_result, word replace
xtreg Pulsator_lv1 GDPpc_GR CPI Pop_GR Adult_R Urban_R PubFC HA_Sales c.Year_code, fe r
outreg2 using wm_fe_result, word
xtreg Pulsator_lowelec GDPpc_GR CPI Pop_GR Adult_R Urban_R PubFC HA_Sales c.Year_code, fe r 
outreg2 using wm_fe_result, word
xtreg Pulsator_lowwater GDPpc_GR CPI Pop_GR Adult_R Urban_R PubFC HA_Sales c.Year_code, fe r
outreg2 using wm_fe_result, word
xtreg Platen_lv1 GDPpc_GR CPI Pop_GR Adult_R Urban_R PubFC HA_Sales c.Year_code, fe r
outreg2 using wm_fe_result, word
xtreg Platen_lowelec GDPpc_GR CPI Pop_GR Adult_R Urban_R PubFC HA_Sales c.Year_code, fe r
outreg2 using wm_fe_result, word
xtreg Platen_lowwater GDPpc_GR CPI Pop_GR Adult_R Urban_R PubFC HA_Sales c.Year_code, fe r
outreg2 using wm_fe_result, word
xtreg WH_lv1 GDPpc_GR CPI Pop_GR Adult_R Urban_R PubFC HA_Sales c.Year_code, fe r
outreg2 using wh_fe_result, word replace
xtreg Elecwh_lv1 GDPpc_GR CPI Pop_GR Adult_R Urban_R PubFC HA_Sales c.Year_code, fe r
outreg2 using wh_fe_result, word
xtreg Gaswh_lv1 GDPpc_GR CPI Pop_GR Adult_R Urban_R PubFC HA_Sales c.Year_code, fe r
outreg2 using wh_fe_result, word
xtreg DW_lowwater GDPpc_GR CPI Pop_GR Adult_R Urban_R PubFC HA_Sales c.Year_code, fe r
outreg2 using dw_fe_result, word replace
xtreg DW_lowelec GDPpc_GR CPI Pop_GR Adult_R Urban_R PubFC HA_Sales c.Year_code, fe r 
outreg2 using dw_fe_result, word

* 稳健性检验：缩尾
winsor2 Pulsator_lv1 Pulsator_lowelec Pulsator_lowwater Platen_lv1 Platen_lowelec Platen_lowwater Elecwh_lv1 Gaswh_lv1 DW_lowwater DW_lowelec WM_lv1 WH_lv1, cuts(0 99) suffix(_t1)
xtreg WM_lv1_t1 GDPpc_GR CPI Pop_GR Adult_R Urban_R PubFC HA_Sales c.Year_code, fe
outreg2 using wm_fe_result_t5, word replace
xtreg Pulsator_lv1_t1 GDPpc_GR CPI Pop_GR Adult_R Urban_R PubFC HA_Sales c.Year_code, fe
outreg2 using wm_fe_result_t5, word
xtreg Pulsator_lowelec_t1 GDPpc_GR CPI Pop_GR Adult_R Urban_R PubFC HA_Sales c.Year_code, fe
outreg2 using wm_fe_result_t5, word
xtreg Pulsator_lowwater_t1 GDPpc_GR CPI Pop_GR Adult_R Urban_R PubFC HA_Sales c.Year_code, fe
outreg2 using wm_fe_result_t5, word
xtreg Platen_lv1_t1 GDPpc_GR CPI Pop_GR Adult_R Urban_R PubFC HA_Sales c.Year_code, fe
outreg2 using wm_fe_result_t5, word
xtreg Platen_lowelec_t1 GDPpc_GR CPI Pop_GR Adult_R Urban_R PubFC HA_Sales c.Year_code, fe
outreg2 using wm_fe_result_t5, word
xtreg Platen_lowwater_t1 GDPpc_GR CPI Pop_GR Adult_R Urban_R PubFC HA_Sales c.Year_code, fe
outreg2 using wm_fe_result_t5, word
xtreg WH_lv1_t1 GDPpc_GR CPI Pop_GR Adult_R Urban_R PubFC HA_Sales c.Year_code, fe
outreg2 using wh_fe_result_t5, word replace
xtreg Elecwh_lv1_t1 GDPpc_GR CPI Pop_GR Adult_R Urban_R PubFC HA_Sales c.Year_code, fe
outreg2 using wh_fe_result_t5, word
xtreg Gaswh_lv1_t1 GDPpc_GR CPI Pop_GR Adult_R Urban_R PubFC HA_Sales c.Year_code, fe
outreg2 using wh_fe_result_t5, word
xtreg DW_lowwater_t1 GDPpc_GR CPI Pop_GR Adult_R Urban_R PubFC HA_Sales c.Year_code, fe
outreg2 using dw_fe_result_t5, word replace
xtreg DW_lowelec_t1 GDPpc_GR CPI Pop_GR Adult_R Urban_R PubFC HA_Sales c.Year_code, fe
outreg2 using dw_fe_result_t5, word

* 稳健性检验：增添变量
xtreg WM_lv1 GDPpc_GR CPI Pop_GR Adult_R Urban_R PubFC HA_Sales HACost c.Year_code, fe
outreg2 using wm_fe_result_hac, word replace
xtreg Pulsator_lv1 GDPpc_GR CPI Pop_GR Adult_R Urban_R PubFC HA_Sales HACost c.Year_code, fe
outreg2 using wm_fe_result_hac, word
xtreg Pulsator_lowelec GDPpc_GR CPI Pop_GR Adult_R Urban_R PubFC HA_Sales HACost c.Year_code, fe
outreg2 using wm_fe_result_hac, word
xtreg Pulsator_lowwater GDPpc_GR CPI Pop_GR Adult_R Urban_R PubFC HA_Sales HACost c.Year_code, fe
outreg2 using wm_fe_result_hac, word
xtreg Platen_lv1 GDPpc_GR CPI Pop_GR Adult_R Urban_R PubFC HA_Sales HACost c.Year_code, fe
outreg2 using wm_fe_result_hac, word
xtreg Platen_lowelec GDPpc_GR CPI Pop_GR Adult_R Urban_R PubFC HA_Sales HACost c.Year_code, fe
outreg2 using wm_fe_result_hac, word
xtreg Platen_lowwater GDPpc_GR CPI Pop_GR Adult_R Urban_R PubFC HA_Sales HACost c.Year_code, fe
outreg2 using wm_fe_result_hac, word
xtreg WH_lv1 GDPpc_GR CPI Pop_GR Adult_R Urban_R PubFC HA_Sales HACost c.Year_code, fe
outreg2 using wh_fe_result_hac, word replace
xtreg Elecwh_lv1 GDPpc_GR CPI Pop_GR Adult_R Urban_R PubFC HA_Sales HACost c.Year_code, fe
outreg2 using wh_fe_result_hac, word
xtreg Gaswh_lv1 GDPpc_GR CPI Pop_GR Adult_R Urban_R PubFC HA_Sales HACost c.Year_code, fe
outreg2 using wh_fe_result_hac, word
xtreg DW_lowwater GDPpc_GR CPI Pop_GR Adult_R Urban_R PubFC HA_Sales HACost c.Year_code, fe
outreg2 using dw_fe_result_hac, word replace
xtreg DW_lowelec GDPpc_GR CPI Pop_GR Adult_R Urban_R PubFC HA_Sales HACost c.Year_code, fe
outreg2 using dw_fe_result_hac, word

* 稳健性检验：更换变量
xtreg WM_lv1 GDPpc_GR CPI Pop_GR Adult_R Urban_R PubFC HA_Sales c.Year_code, fe
outreg2 using wm_fe_result, word replace
xtreg Pulsator_lv1 GDPpc_GR CPI Pop_GR Adult_R Urban_R PubFC HA_Sales c.Year_code, fe
outreg2 using wm_fe_result, word
xtreg Pulsator_lowelec GDPpc_GR CPI Pop_GR Adult_R Urban_R PubFC HA_Sales c.Year_code, fe
outreg2 using wm_fe_result, word
xtreg Pulsator_lowwater GDPpc_GR CPI Pop_GR Adult_R Urban_R PubFC HA_Sales c.Year_code, fe
outreg2 using wm_fe_result, word
xtreg Platen_lv1 GDPpc_GR CPI Pop_GR Adult_R Urban_R PubFC HA_Sales c.Year_code, fe
outreg2 using wm_fe_result, word
xtreg Platen_lowelec GDPpc_GR CPI Pop_GR Adult_R Urban_R PubFC HA_Sales c.Year_code, fe
outreg2 using wm_fe_result, word
xtreg Platen_lowwater GDPpc_GR CPI Pop_GR Adult_R Urban_R PubFC HA_Sales c.Year_code, fe
outreg2 using wm_fe_result, word
xtreg WH_lv1 GDPpc_GR CPI Pop_GR Adult_R Urban_R PubFC HA_Sales c.Year_code, fe
outreg2 using wh_fe_result, word replace
xtreg Elecwh_lv1 GDPpc_GR CPI Pop_GR Adult_R Urban_R PubFC HA_Sales c.Year_code, fe
outreg2 using wh_fe_result, word
xtreg Gaswh_lv1 GDPpc_GR CPI Pop_GR Adult_R Urban_R PubFC HA_Sales c.Year_code, fe
outreg2 using wh_fe_result, word
xtreg DW_lowwater GDPpc_GR CPI Pop_GR Adult_R Urban_R PubFC HA_Sales c.Year_code, fe
outreg2 using dw_fe_result, word replace
xtreg DW_lowelec GDPpc_GR CPI Pop_GR Adult_R Urban_R PubFC HA_Sales c.Year_code, fe
outreg2 using dw_fe_result, word
