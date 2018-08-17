
# PlanAhead Launch Script for Post-Synthesis floorplanning, created by Project Navigator

create_project -name zxuno_xs6_vp -dir "/media/datos/Devel/xilinxise/COMPILACION_DE_PROYECTOS/fpga_videopac/syn/ZX_Uno/bld/planAhead_run_2" -part xc6slx16ftg256-2
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "/media/datos/Devel/xilinxise/COMPILACION_DE_PROYECTOS/fpga_videopac/syn/ZX_Uno/bld/zxuno_xs6_vp.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {/media/datos/Devel/xilinxise/COMPILACION_DE_PROYECTOS/fpga_videopac/syn/ZX_Uno/bld} }
set_property target_constrs_file "temp.ucf" [current_fileset -constrset]
add_files [list {temp.ucf}] -fileset [get_property constrset [current_run]]
link_design
