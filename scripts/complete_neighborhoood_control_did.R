## DiD for inviales with IMS using all untreated neighborhoods as control, filtering until the stops happen
# DAOA 
# 26/10/2024

# Preparar Espacio --------------------------------------------------------

dev.off()
rm(list = ls())
options(scipen = 999)
pacman::p_load(tidyverse, scales, did, sf)
set.seed(99)

# Cargar Datos ------------------------------------------------------------

# Bases producidas con el script: generador_base_incidentes_img20
load(file = 'output/bases_completas.RData')

# Crear base --------------------------------------------------------------

# Numeric
# Needed for the package
complete_total$dates_complete %>% min()
complete_total$dates_complete %>% max()

# Remove 2013
dummy_dates <- data.frame(dates_complete = seq.Date(as.Date("2014-01-01"),as.Date("2023-08-01"), 
                                                    by = '1 month'),date_numeric = 1:length(unique(complete_total$dates_complete)))
dummy_id <- complete_total %>% count(CVE_COL) %>% mutate(ID = 1:2243) %>% select(-n)

base_did_inviales <- complete_total %>% 
  left_join(dummy_dates) %>% 
  left_join(dummy_id) %>% 
  mutate(start =  cb_1b * 91 + cb_2b * 92 + tr_eb * 106 + tr_9 * 85) %>% 
  mutate(start = ifelse(start == 198, 92,start)) %>% 
  mutate(stop = l_12b * 89 + l_1b * 103) %>% 
  select(ID, CVE_COL, date_numeric, total_inviales = incidencia, start, stop) 

# Quitamos observación de Diciembre 2013
base_did_inviales <- base_did_inviales %>% filter(!is.na(date_numeric))

# atropellados

atropellados_did <- complete_atropellado_lesionado  %>% 
  left_join(dummy_dates) %>% 
  left_join(dummy_id) %>% 
  mutate(start =  cb_1b * 91 + cb_2b * 92 + tr_eb * 106 + tr_9 * 85) %>% 
  mutate(start = ifelse(start == 198, 92,start)) %>% 
  mutate(stop = l_12b * 89 + l_1b * 103) %>% 
  select(ID, date_numeric, atropellados = incidencia) 

# choque con lesionados

choquecl_did <- complete_choque_cl_accidente  %>% 
  left_join(dummy_dates) %>% 
  left_join(dummy_id) %>% 
  mutate(start =  cb_1b * 91 + cb_2b * 92 + tr_eb * 106 + tr_9 * 85) %>% 
  mutate(start = ifelse(start == 198, 92,start)) %>% 
  mutate(stop = l_12b * 89 + l_1b * 103) %>% 
  select(ID, date_numeric, choque_cl = incidencia) 

# chocque sin lesionados

choquesl_did <- complete_choque_sl_accidente %>% 
  left_join(dummy_dates) %>% 
  left_join(dummy_id) %>% 
  mutate(start =  cb_1b * 91 + cb_2b * 92 + tr_eb * 106 + tr_9 * 85) %>% 
  mutate(start = ifelse(start == 198, 92,start)) %>% 
  mutate(stop = l_12b * 89 + l_1b * 103) %>% 
  select(ID, date_numeric, choque_sl = incidencia) 

# accidentes moto

accidentes_moto_did <- complete_moto_accidente  %>% 
  left_join(dummy_dates) %>% 
  left_join(dummy_id) %>% 
  mutate(start =  cb_1b * 91 + cb_2b * 92 + tr_eb * 106 + tr_9 * 85) %>% 
  mutate(start = ifelse(start == 198, 92,start)) %>% 
  mutate(stop = l_12b * 89 + l_1b * 103) %>% 
  select(ID, date_numeric, accidente_moto = incidencia) 

# Total

total_accidentes_viales <- complete_total  %>% 
  left_join(dummy_dates) %>% 
  left_join(dummy_id) %>% 
  mutate(start =  cb_1b * 91 + cb_2b * 92 + tr_eb * 106 + tr_9 * 85) %>% 
  mutate(start = ifelse(start == 198, 92,start)) %>% 
  mutate(stop = l_12b * 89 + l_1b * 103) %>% 
  select(ID, date_numeric, total = incidencia) 

# pegamos otros choques a la base completa

base_did_inviales <- base_did_inviales %>% 
  left_join(atropellados_did, by = c('ID', 'date_numeric')) %>% 
  left_join(choquecl_did, by = c('ID', 'date_numeric')) %>% 
  left_join(choquesl_did, by = c('ID', 'date_numeric')) %>% 
  left_join(accidentes_moto_did, by = c('ID', 'date_numeric')) %>%   # late registration
  left_join(total_accidentes_viales, by = c('ID', 'date_numeric')) %>% 
  filter(!is.na(date_numeric))

# Separate ----------------------------------------------------------------

# Filter Start

base_did_inviales %>% filter(stop == 0) %>% count(start)
base_did_inviales %>% count(start)
base_did_inviales %>% filter(start == 0) %>% count(stop)
base_did_inviales %>% count(stop)

did_inviales_start <- base_did_inviales %>% filter(stop == 0)

# Filter Stop

did_inviales_stop <- base_did_inviales %>% filter(start == 0,
                                                  date_numeric <= 108 # Enero 2023
                                                  ) 

# save(did_inviales_start, did_inviales_stop, file = 'output/complete_did_database.RData')
load(file = 'output/complete_did_database.RData')

# Did ---------------------------------------------------------------------

# Complete Start
did_total_start <- att_gt(
  yname = "total",
  tname = "date_numeric",
  idname = "ID",
  gname = "start",
  data = did_inviales_start
)
did_choquecl_start <- att_gt(
  yname = "choque_cl",
  tname = "date_numeric",
  idname = "ID",
  gname = "start",
  data = did_inviales_start
)
did_choquesl_start <- att_gt(
  yname = "choque_sl",
  tname = "date_numeric",
  idname = "ID",
  gname = "start",
  data = did_inviales_start
)
did_moto_start <- att_gt(
  yname = "accidente_moto",
  tname = "date_numeric",
  idname = "ID",
  gname = "start",
  data = did_inviales_start
)
did_atropellados_start <- att_gt(
  yname = "atropellados",
  tname = "date_numeric",
  idname = "ID",
  gname = "start",
  data = did_inviales_start
)



# Stop
did_total_stop <- att_gt(
  yname = "total",
  tname = "date_numeric",
  idname = "ID",
  gname = "stop",
  data = did_inviales_stop
)

did_choquecl_stop <- att_gt(
  yname = "choque_cl",
  tname = "date_numeric",
  idname = "ID",
  gname = "stop",
  data = did_inviales_stop
)
did_choquesl_stop <- att_gt(
  yname = "choque_sl",
  tname = "date_numeric",
  idname = "ID",
  gname = "stop",
  data = did_inviales_stop
)
did_moto_stop <- att_gt(
  yname = "accidente_moto",
  tname = "date_numeric",
  idname = "ID",
  gname = "stop",
  data = did_inviales_stop
)
did_atropellados_stop <- att_gt(
  yname = "atropellados",
  tname = "date_numeric",
  idname = "ID",
  gname = "stop",
  data = did_inviales_stop
)


# Simple ATT --------------------------------------------------------------

# Simple: ATT
# Creates a weighted average of all group-time average treatment effects with weights proportional to group size
set.seed(99)
agg_start_complete <- aggte(did_total_start, type = 'simple', na.rm = T)
agg_start_choquecl <- aggte(did_choquecl_start, type = 'simple', na.rm = T)
agg_start_choquesl <- aggte(did_choquesl_start, type = 'simple', na.rm = T)
agg_start_atropellados <- aggte(did_atropellados_start, type = 'simple', na.rm = T)
agg_start_moto <- aggte(did_moto_start, type = 'simple', na.rm = T)


# ATT starts
kableExtra::kable(data.frame(incidente = c('total', 'choque con lesionados', 'choque sin lesionados', 'atropellados', 'accidentes en moto'),
                 att_start = c(agg_start_complete$overall.att,
                         agg_start_choquecl$overall.att,
                         agg_start_choquesl$overall.att,
                         agg_start_atropellados$overall.att,
                         agg_start_moto$overall.att), 
                 se = c(agg_start_complete$overall.se,
                        agg_start_choquecl$overall.se,
                        agg_start_choquesl$overall.se,
                        agg_start_atropellados$overall.se,
                        agg_start_moto$overall.se) ) %>%
                   mutate(att_start = round(att_start, 3), 
                          se = round(se, 3), 
                          ) %>% 
        mutate(ce = paste0('[', round(att_start - 1.96*se, 3), ' --- ', round(att_start + 1.96*se,3), ']')), 
      format = 'pipe')

# ATT stops
agg_stop_complete <- aggte(did_total_stop, type = 'simple', na.rm = T)
agg_stop_choquecl <- aggte(did_choquecl_stop, type = 'simple', na.rm = T)
agg_stop_choquesl <- aggte(did_choquesl_stop, type = 'simple', na.rm = T)
agg_stop_atropellados <- aggte(did_atropellados_stop, type = 'simple', na.rm = T)
agg_stop_moto <- aggte(did_moto_stop, type = 'simple', na.rm = T)

kableExtra::kable(data.frame(incidente = c('total', 'choque con lesionados', 'choque sin lesionados', 'atropellados', 'accidentes en moto'),
                 att_stop = c(agg_stop_complete$overall.att,
                         agg_stop_choquecl$overall.att,
                         agg_stop_choquesl$overall.att,
                         agg_stop_atropellados$overall.att,
                         agg_stop_moto$overall.att), 
                 se = c(agg_stop_complete$overall.se,
                        agg_stop_choquecl$overall.se,
                        agg_stop_choquesl$overall.se,
                        agg_stop_atropellados$overall.se,
                        agg_stop_moto$overall.se) ) %>%
                   mutate(att_stop = round(att_stop, 3), se = round(se, 3)) %>% 
        mutate(ce = paste0('[', round(att_stop - 1.96*se, 2), ' --- ', round(att_stop + 1.96*se,2), ']')), 
      format = 'pipe')


# Dynamic ATT(t) - Event Study ---------------------------------------------------

# Dynamic, ATT(t): best agregation
# computes average effects across different lengths of exposure to the treatment and is similar to an "event study"

# Start Group
# Complete
agg_start_complete <- aggte(did_total_start, type = 'dynamic', na.rm = T)
summary(agg_start_complete)
ggdid(agg_start_complete, title = "Dynamic Effect of the start group over All Incidents using all untreated neighborhoods as control", xgap = 5)+
  scale_color_manual(values = c("red", "blue"), 
                     labels = c("Pre", "Post"))
# Crasher without injuries
agg_start_crashes_woi <- aggte(did_choquecl_start, type = 'dynamic', na.rm = T)
summary(agg_start_crashes_woi)
ggdid(agg_start_crashes_woi, title = "Dynamic Effect of the start group over Crashes Without Injuries using all untreated neighborhoods as control", xgap = 5)+
  scale_color_manual(values = c("red", "blue"), 
                     labels = c("Pre", "Post"))
# Crashes with injuries
agg_start_crashes_wi <- aggte(did_choquesl_start, type = 'dynamic', na.rm = T)
summary(agg_start_crashes_wi)
ggdid(agg_start_crashes_wi, title = "Dynamic Effect of the stop group over Crashes With Injuries using all untreated neighborhoods as control", xgap = 5)+
  scale_color_manual(values = c("red", "blue"), 
                     labels = c("Pre", "Post"))
# Runovers
agg_start_runovers <- aggte(did_atropellados_start, type = 'dynamic', na.rm = T)
summary(agg_start_runovers)
ggdid(agg_start_runovers, title = "Dynamic Effect of the stop group over Runovers using all untreated neighborhoods as control", xgap = 5)+
  scale_color_manual(values = c("red", "blue"), 
                     labels = c("Pre", "Post"))
# Motorcycle incidents
agg_start_motorcycles <- aggte(did_moto_start, type = 'dynamic', na.rm = T)
summary(agg_start_motorcycles)
ggdid(agg_start_motorcycles, title = "Dynamic Effect of the stop group over Motorcycle Incidents using all untreated neighborhoods as control", xgap = 5)+
  scale_color_manual(values = c("red", "blue"), 
                     labels = c("Pre", "Post"))

## Stop
# Complete stop
agg_stop_complete <- aggte(did_total_stop, type = 'dynamic', na.rm = T)
summary(agg_stop_complete)
ggdid(agg_stop_complete, title = "Dynamic Effect of the stop group over All Incidents using all untreated neighborhoods as control", xgap = 5)+
  scale_color_manual(values = c("red", "blue"), 
                     labels = c("Pre", "Post"))
# Crashes without injuries
agg_stop_crashes_woi <- aggte(did_choquecl_stop, type = 'dynamic', na.rm = T)
summary(agg_stop_crashes_woi)
ggdid(agg_stop_crashes_woi, title = "Dynamic Effect of the stop group over Crashes Without Injuries using all untreated neighborhoods as control", xgap = 5)+
  scale_color_manual(values = c("red", "blue"), 
                     labels = c("Pre", "Post"))
# Crashes with injuries
agg_stop_crashes_wi <- aggte(did_choquesl_stop, type = 'dynamic', na.rm = T)
summary(agg_stop_crashes_wi)
ggdid(agg_stop_crashes_wi, title = "Dynamic Effect of the stop group over Crashes With Injuries using all untreated neighborhoods as control", xgap = 5)+
  scale_color_manual(values = c("red", "blue"), 
                     labels = c("Pre", "Post"))
# Runovers
agg_stop_runovers <- aggte(did_atropellados_stop, type = 'dynamic', na.rm = T)
summary(agg_stop_runovers)
ggdid(agg_stop_runovers, title = "Dynamic Effect of the stop group over Runovers using all untreated neighborhoods as control", xgap = 5)+
  scale_color_manual(values = c("red", "blue"), 
                     labels = c("Pre", "Post"))
# Motorcycle incidents
agg_stop_motorcycles <- aggte(did_moto_stop, type = 'dynamic', na.rm = T)
summary(agg_stop_motorcycles)
ggdid(agg_stop_motorcycles, title = "Dynamic Effect of the stop group over Motorcycle Incidents using all untreated neighborhoods as control", xgap = 5)+
  scale_color_manual(values = c("red", "blue"), 
                     labels = c("Pre", "Post"))

# Group Effect - ATT(g) ---------------------------------------------------

###################### Start

set.seed(99)
# Group Effect (ATT(g))
# (this is the default option and computes average treatment effects across 
# different groups; here the overall effect averages the effect across different group

# Complete
agg_start_complete <- aggte(did_total_start, type = 'group', na.rm = T)
summary(agg_start_complete)
ggdid(agg_start_complete)


# Choques con Lesionado
agg_start_choquecl <- aggte(did_choquecl_start, type = 'group', na.rm = T)
summary(agg_start_choquecl)
ggdid(agg_start_choquecl)


# Choques sin Lesionados
agg_start_choquesl <- aggte(did_choquesl_start, type = 'group', na.rm = T)
summary(agg_start_choquesl)
ggdid(agg_start_choquesl)

# Atropellados
agg_start_atropellados <- aggte(did_atropellados_start, type = 'group', na.rm = T)
summary(agg_start_atropellados)
ggdid(agg_start_atropellados)

# Accidentes en Moto
agg_start_moto <- aggte(did_moto_start, type = 'group', na.rm = T)
summary(agg_start_moto)
ggdid(agg_start_moto)

## Stop

# Group Effect (ATT(g))
# (this is the default option and computes average treatment effects across 
# different groups; here the overall effect averages the effect across different group

# Complete
agg_stop_complete <- aggte(did_total_stop, type = 'group', na.rm = T)
summary(agg_stop_complete)
ggdid(agg_stop_complete)

# Choques con Lesionado
agg_stop_choquecl <- aggte(did_choquecl_stop, type = 'group', na.rm = T)
summary(agg_stop_choquecl)
ggdid(agg_stop_choquecl)

# Choques sin Lesionados
agg_stop_choquesl <- aggte(did_choquesl_stop, type = 'group', na.rm = T)
summary(agg_stop_choquesl)
ggdid(agg_stop_choquesl)

# Atropellados
agg_stop_atropellados <- aggte(did_atropellados_stop, type = 'group', na.rm = T)
summary(agg_stop_atropellados)
ggdid(agg_stop_atropellados)

# Accidentes en Moto
agg_stop_moto <- aggte(did_moto_stop, type = 'group', na.rm = T)
summary(agg_stop_moto)
ggdid(agg_stop_moto)

