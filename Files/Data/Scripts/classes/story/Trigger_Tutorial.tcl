def_class Trigger_Tutorial none dummy 0 {} {
	call scripts/misc/info_obj.tcl
	def_event evt_timer0
	def_event evt_timer1
	def_event selfdestroy
	def_event evt_system_gamestart
	method set_tournament {} {
		set tutorial 0
	}
	state task {
		if {[tasklist_cnt this]>0} {
			set nexttask [tasklist_get this 0]
			tasklist_rem this 0
			eval $nexttask
		} else {
			state_triggerfresh this checking
			set wait_increase 0
		}
	}
	state correction {
		if { 0 && [get_sequencebreaked] } {
			eval "set_view $standardview"
			state_triggerfresh this task
			viewlock 0
			set_sequenceactive this 0
		}
		incr correctioncount
//		log cameracorrection
		if {$correctioncount<200} {
			for {set i 0} {$i<5} {incr i} {
				if {abs([lindex $standardview $i]-[lindex [get_view] $i])>0.2-0.05*($i/2)+$correctioncount+0.01} {
					state_disable this
					action this wait 0.5 {state_enable this}
					return
				}
			}
		}
		set correctioncount 0
		log "beendet [get_view]"
		if {$releaseaftercorrection} {
			viewlock 0
			set_sequenceactive this 0
		}
		state_triggerfresh this task
	}
	state checking {
		set positiv 0
		foreach possibility $tocheck {
			if {[set positiv [check_callback $possibility]]==""} {
				log "undefined possibility: $possibility"
				set positiv 0
			} else {
				if {$positiv} {
					break
				}
			}
		}
		if {$positiv} {
			if {$possibility!="markedhigh"} {
				log "activated option: $possibility"
				gametime factor 1.0
			}
			switch $possibility {
				"truereturn" {
					if {!$tutorial} {self_destroy;return}
					log "initializing gnome now. ([obj_query this -class Zwerg -owner 0 -cloaked 1]) [get_pos this]"
					set gnome_ref1 [obj_query this "-class Zwerg -owner 0 -range 20 -limit 1 -cloaked 1"]
					if {$gnome_ref1} {log "Zwergenposition [get_pos $gnome_ref1]"}
					set gnomename1 [get_objname $gnome_ref1]
					set gnomegender1 [get_objgender $gnome_ref1]
					set standardview "[lindex $mypos 0] [expr {[lindex $mypos 1] -1.1}] 1.5 -0.2 0.0"
					eval "set_view $standardview 1"
					tasklist_add this "elf_action -set \{[vector_add [get_pos $gnome_ref1] {-2 -2 0}]\} -wait 1"
					set tocheck "gnomereached"
					//Variablen initialisieren
					set gatter1 [obj_query this -class Zauntor_a -range 30]
					if {[lindex $gatter1 1]==""||[get_posx [lindex $gatter1 0]]<[get_posx [lindex $gatter1 1]]} {
						set gatter1 [lindex $gatter1 0] } { set gatter1 [lindex $gatter1 1]
					}
					set coal [obj_query this -class Kohle -range 30 -limit 1]
					set door [obj_query this -class Tuer_kaserne range 70 -limit 1]
					set door2 [obj_query $door -class Tuer_kaserne range 70 -limit 1]
					set collbox [lindex [obj_query $door -class Info_Coll_o -range 100 -limit 2] 1]
					set rightdig [vector_add $mypos {-63.7 -1 6}]
					set leftdig [vector_add $mypos {-78.9 -1.6 6}]
					set cavedigy [expr {[lindex $mypos 1]-10.0}]
					set upperdig [vector_add $mypos {-101.7 0.2 6}]
					set lowerdig [vector_add $mypos {-101.4 3.5 6}]
					set digwatchright [vector_add $rightdig {2 0 0}]
					set digwatchleft [vector_add $leftdig {-10 -1 0}]
					set digwatchup [vector_add $mypos {-74.7 -8 6}]
					set digwatchlow [vector_add $lowerdig {0 2 0}]
					set cavedig1 [vector_add $mypos {-75 -1.3 0}]
					set cavedig2 [lindex $cavedig1 1]
					set cavedig1 [lindex $cavedig1 0]
					set digwatchtunnel [vector_add $mypos {-75.1 0.6 6}]
					set puppet1 [obj_query this -class Trainingspuppe -limit 1]
					set puppet2 [obj_query $puppet1 -class Holzpuppe -boundingbox {0 -1 -3 5 1 3}]
					set_owner $puppet1 1
					set_owner $puppet2 0
					set_selectable $puppet2 0
					set_diplomacy 0 1 "neutral"
					set_owner_attrib 0 digenable0 0
					set_owner_attrib 0 digenable1 0
					set_owner_attrib 0 digenable2 0
					set_owner_attrib 0 digenable3 0
					set_owner_attrib 0 digenable4 0
					prodslot_override disable 0
					prodslot_override disable 1
					prodslot_override disable 2
					prodslot_override disable 3
					prodslot_override disable 4
					prodslot_override disable 5
					prodslot_override disable 31
				}
				"gnomereached" {
					soundfile_open 1010a1105m
					tasklist_add this "elf_action -move \{[vector_add [get_pos $gnome_ref1] {-2 -2 0}]\} -wait 7"
					tasklist_add this "elf_action -anim zeigen_rechts -speak 1010a"
					tasklist_add this "elf_action -anim reden_b -speak 1010z"
					tasklist_add this "elf_action -anim auffordern -speak 1200"
					set tocheck "gnomedied perspective"
					set try_increase 0
					set comp_val [lrange [get_view] 3 4]
					tasklist_add this "task_to_ticker 1001a"
				}
				"gnomedied" {
					clear_ticker
					viewlock 1
					tasklist_add this "elf_action -anim verzweifeln -wait =5"
					start_fade 0 2
					prodslot_override reset
					tasklist_add this "game_over"
					set tocheck ""
				}
				"perspective" {
					tasklist_add this "cameracorrection 1 0.2 0.7"
					tasklist_add this "elf_action -anim zustimmen -speak 1010b"
					tasklist_add this "elf_action -anim reden_a -speak 1210"
					set tocheck "gnomedied zoom"
					set try_increase 0
					set comp_val [lindex [get_view] 2]
					clear_ticker
					tasklist_add this "task_to_ticker 1001b"
				}
				"zoom" {
					tasklist_add this "cameracorrection 1 1 0.5"
					tasklist_add this "elf_action -anim reden_b -speak 1220"
					tasklist_add this "elf_action -anim auffordern -speak 1010c"
					set tocheck "gnomedied viewtarget"
					set comp_val [lrange [get_view] 0 1]
					set try_increase 0
					clear_ticker
					tasklist_add this "task_to_ticker 1001c"
				}
				"viewtarget" {
					tasklist_add this "cameracorrection 3 0.3 0.3"
//					tasklist_add this "elf_action -screen \{200 200 16\}"
					tasklist_add this "elf_action -anim zustimmen -speak 1010d"
					tasklist_add this "elf_action -anim reden_a -speak 1010e"
					clear_ticker
					set tocheck "gnomedied beforeselecting"
				}
				"beforeselecting" {
					if {[check_callback gnome1selected]} {
						tasklist_add this "elf_action -anim zustimmen -speak 1010k"
						set othervar false
					} else {
						tasklist_add this "elf_action -anim reden_b -speak 1230"
						set othervar true
					}
					set tocheck "gnomedied gnome1selected"
					tasklist_add this "task_to_ticker 1001d"
				}
				"gnome1selected" {
					if {$othervar} { tasklist_add this "elf_action -anim zustimmen -speak 1010j" }
					tasklist_add this "elf_action -anim zeigen_rechts -speak 1010f"
					tasklist_add this "elf_action -anim reden_a -speak 1235"
					set tocheck "gnomedied gnome1deselected"
					clear_ticker
					tasklist_add this "task_to_ticker 1001e"
				}
				"gnome1deselected" {
					tasklist_add this "elf_action -anim koketieren -speak 1105j"
					set tocheck "gnomedied .gnome1selected"
					clear_ticker
					tasklist_add this "task_to_ticker 1001f"
					}
				".gnome1selected" {
					tasklist_add this "elf_action -anim reden_b -speak 1240"
					tasklist_add this "elf_action -anim reden_b -speak 1010y"
					set tocheck "gnomedied .gnome1deselected gnomehaswalked"
					set comp_val [get_pos $gnome_ref1]
					set try_increase 0
					clear_ticker
					tasklist_add this "task_to_ticker 1001g"
				}
				".gnome1deselected" {
					tasklist_add this "elf_action -anim verzweifeln -speak 1105h"
					set tocheck "gnomedied wronglydeselected gnomehaswalked"
				}
				"wronglydeselected" {
					tasklist_add this "elf_action -anim reden_a -speak 1225"
					set tocheck "gnomedied wronglydeselected. gnomehaswalked"
				}
				"wronglydeselected." {
					tasklist_add this "elf_action -anim reden_b -speak 1230"
					set tocheck [lreplace $tocheck 1 1]
				}
				"gnomehaswalked" {
					tasklist_add this "elf_action -anim zeigen_links -speak 1010g"
					set tocheck "gnomedied gnomewalkedright gnomewalkedwrong"
					set walktarget [get_pos $gatter1]
					set comp_val [vector_dist [get_pos $gnome_ref1] $walktarget]
					clear_ticker
					tasklist_add this "task_to_ticker 1001h"
				}
				"gnomewalkedwrong" {
					tasklist_add this "elf_action -anim beleidigen -speak 1010h"
					set othervar "walkedwrong"
					set tocheck [lreplace $tocheck end end]
				}
				"gnomewalkedright" {
					tasklist_add this "viewlock 1; set_sequenceactive this 1"
					tasklist_add this "set_viewpos [get_pos $gatter1] 1.2 -0.2 -0.3 1"
					tasklist_add this "elf_action -screen none -move \{[vector_add [get_pos $gatter1] {0 -2 0}]\} -wait 3"
					tasklist_add this "call_method $gatter1 oeffnen -1"
					if {$othervar=="walkedwrong"} {
						tasklist_add this "elf_action -anim salto -speak 1010i -wait =0"
					} else {
						tasklist_add this "elf_action -anim salto -speak 1010j -wait =0"
					}
					tasklist_add this "call_method $gatter1 oeffnen -1"
					tasklist_add this "elf_action -wait 2"
					tasklist_add this "set_viewpos [get_pos $coal] 1.2 -0.2 0.6 1"
					tasklist_add this "elf_action -move \{[vector_add [get_pos $gatter1] {-5 -2 0}]\} -speak 1105a -wait 5"
					tasklist_add this "viewlock 0"
					tasklist_add this "eval \"set_view \[lreplace \[get_view\] 2 2 1.5\] 1\""
					tasklist_add this "elf_action -moveexact \{[vector_add [get_pos $coal] {0 -2 0}]\} -wait 3"
					tasklist_add this "elf_action -anim reden_a -speak 1105b -wait 5"
					tasklist_add this "elf_action -screen \{400 -100 17\}"
					set tocheck "gnomedied stonein wronglydeselected.."
					clear_ticker
					tasklist_add this "task_to_ticker 1001i"
				}
				"wronglydeselected.." {
					tasklist_add this "elf_action -anim verzweifeln -speak 1105c"
					append tocheck "."
				}
				"wronglydeselected..." {
					tasklist_add this "elf_action -anim reden_a -speak 1230"
					set tocheck "gnomedied stonein"
				}
				"stonein" {
					clear_ticker
					set_sequenceactive this 0
					if {[check_callback gnome1deselected]} {
						tasklist_add this "elf_action -anim auffordern -speak 1105j"
						set tocheck "gnomedied gnome1selected. .wronglydeselected..."
					} else {
						set tocheck "gnomedied gnome1selected."
					}
				}
				".wronglydeselected..." {
					tasklist_add this "elf_action -anim verzweifeln -speak 1230"
					set tocheck "gnomedied gnome1selected."
				}
				"gnome1selected." {
					tasklist_add this "elf_action -screen \{400 -100 17\}"
					tasklist_add this "elf_action -anim zeigen_links -speak 1105d"
					tasklist_add this "elf_action -screen \{300 150 16\} -speak 1105f"
					tasklist_add this "elf_action -wait 1"
					tasklist_add this "elf_action -screen none -move \{[vector_add $mypos {-38.044 -2.04 0.88}]\} -wait =8"
					tasklist_add this "elf_action -screen none -move \{[vector_add $mypos {-38.044 -2.04 0.88}]\} -wait =4"
					set tocheck "gnomedied gnomenearelf ..wronglydeselected..."
					tasklist_add this "task_to_ticker 1001j"
				}
				"..wronglydeselected..." {
					tasklist_add this "elf_action -anim reden_a -speak 1225"
					set tocheck "gnomedied gnomenearelf"
				}
				"gnomenearelf" {
					clear_ticker
					if {[check_callback gnome1selected]} {
						tasklist_add this "elf_action -anim zustimmen -speak 1105m"
						tasklist_add this "task_to_ticker 1001l"
					}
					set tocheck "gnomedied gnome1deselected..."
				}
				"gnomenearelf." {
					// (alt)
					elf screen {200 200 16}
					if {[check_callback stoneout]} {
						tasklist_add this "elf_action -anim schmollen -speak 1105i"
						set tocheck "gnomedied stoneout"
					} else {
						tasklist_add this "elf_action -anim reden_a -speak 1105g"
						set tocheck "gnomedied stoneout gnome1deselected.."
					}
					clear_ticker
					tasklist_add this "task_to_ticker 1001k"
				}
				"gnome1deselected.." {
					// nicht aktiv
					tasklist_add this "elf_action -anim warnen -speak 1105h"
					set tocheck "gnomedied stoneout wronglydeselected...."
				}
				"wronglydeselected...." {
					// nicht aktiv
					tasklist_add this "elf_action -anim reden_b -speak 1225"
					set tocheck "gnomedied stoneout"
				}
				"stoneout" {
					// nicht aktiv
					if {[check_callback gnome1selected]} {
						tasklist_add this "elf_action -anim zustimmen -speak 1105m"
					}
					set tocheck "gnomedied gnome1deselected..."
					clear_ticker
					tasklist_add this "task_to_ticker 1001l"
				}
				"gnome1deselected..." {
					set stones [obj_query this "-class Stein -range 200"]
					foreach i $stones {
						set_lock $i 1
					}
					tasklist_add this "set_viewpos [lrange [get_pos $gnome_ref1] 0 1] 13 1.4 -0.2 0.2 1"
					tasklist_add this "elf_action -screen none -wait =1"
					tasklist_add this "elf hide"
					tasklist_add this "elf_action -wait 5"
					sel /obj
					set gnome_ref2 [new Zwerg "" [concat [lrange [vector_add [get_pos $gnome_ref1] {15 0 0}] 0 1] 12] {0 1.57 0}]
					call_method $gnome_ref2 Editor_Set_Info {{gender female} {name Trine}}
					set_owner $gnome_ref2 0
					set_physic $gnome_ref2 false
					set_autolight $gnome_ref2 true
					call_method $gnome_ref2 disable_reprod
					set fireplace [new Feuerstelle "" {0.0 0.0 0.0} {0.0 0.0 0.0}]
					call_method $fireplace packtobox
					set_physic $fireplace true
					set_autolight $fireplace false
					set_owner $fireplace 0
					inv_add $gnome_ref2 $fireplace
					set tocheck "truereturn."
					clear_ticker
				}
				"truereturn." {
					set gnomename2 [get_objname $gnome_ref2]
					set gnomegender2 [get_objgender $gnome_ref2]
					set_worktime $gnome_ref2 6.0 6.0
					create_trigger $gnome_ref1 "Tut_2010"
					set tocheck ".truereturn."
				}
				".truereturn." {
					soundfile_open 1270a1120g
					tasklist_add this "elf_action -setexact \{[vector_add [concat [lrange [get_view] 0 1] 16] {-10 -5 0}]\} -wait =1"
					tasklist_add this "elf_action -moveexact \{[vector_add [concat [lrange [get_view] 0 1] 16] {-5 -5 0}]\} -wait =7"
					tasklist_add this "elf_action -screen \{200 200 16\}"
					tasklist_add this "elf_action -anim reden_a -speak 1270a"
					tasklist_add this "elf_action -anim reden_b -speak 1270z"
					set tocheck "gnomedied .fireselected fireplaceininv"
					tasklist_add this "task_to_ticker 1001m"
				}
				".fireselected" {
					tasklist_add this "elf_action -screen \{200 200 16\}"
					tasklist_add this "elf_action -anim reden_a -speak 1270y"
					tasklist_add this "elf_action -anim reden_b -speak 1270z"
					set tocheck "gnomedied fireplaceininv"
				}
				"fireplaceininv" {
					clear_ticker
					tasklist_add this "elf_action -screen \{200 200 16\}"
					tasklist_add this "elf_action -anim reden_a -speak 1270b"
					set tocheck "gnomedied fireplaceonmouse fireplaceunbuilt fireplaceunpacked"
					tasklist_add this "task_to_ticker 1001z"
				}
				"fireplaceonmouse" {
					clear_ticker
					tasklist_add this "elf_action -screen \{200 200 16\}"
					tasklist_add this "elf_action -anim reden_b -speak 1270c"
					tasklist_add this "elf_action -anim reden_a -speak 1270d"
					set tocheck "gnomedied fireplacegreen fireplaceunpacked fireplacewrong fireplaceunbuilt fireplacebox"
				}
				"fireplacegreen" {
					tasklist_add this "elf_action -anim reden_b -speak 1270e"
					tasklist_add this "task_to_ticker 1001n"
					lrem tocheck 1
				}
				"fireplacebox" {
					tasklist_add this "elf_action -anim reden_b -speak 1270f"
					set tocheck [lreplace $tocheck end end]
				}
				"fireplacewrong" {
					tasklist_add this "elf_action -anim verzweifeln -speak 1270g"
					tasklist_add this "elf_action -anim reden_b -speak 1270z"
					set tocheck "gnomedied .fireselected fireplaceininv"
				}
				"fireplaceunbuilt" {
					set tocheck "gnomedied fireplaceunpacked fireplacewrong fireplacebox"
					tasklist_add this "task_to_ticker 1001y"
				}
				"fireplaceunpacked" {
					change_particlesource $fireplace 1 6 {0 0 0} {0.25 0 0} 8 1 0 6 30
					set_particlesource $fireplace 1 1
					elf unfollowview
					tasklist_add this "elf_action -anim pirouette -speak 1270h"
					tasklist_add this "elf_action -screen \{300 200 16\}"
//					tasklist_add this "elf_action -screen none"
					tasklist_add this "elf_action -anim zustimmen -speak 1120a"
					tasklist_add this "elf_action -screen \{300 200 16\}"
					tasklist_add this "elf_action -anim reden_a -speak 1120b"
					tasklist_add this "elf_action -screen \{300 200 16\}"
					tasklist_add this "elf_action -anim reden_b -speak 1120c"
					set tocheck "gnomedied truereturn.."
					clear_ticker
				}
				"truereturn.." {
					tasklist_add this "elf_action -screen \{300 200 16\}"
					if {[check_callback "stoneout"]} {
						tasklist_add this "elf_action -anim schmollen -speak 1105i"
					} else {
						tasklist_add this "elf_action -anim reden_a -speak 1105g"
						tasklist_add this "task_to_ticker 1001k"
					}
					set tocheck "gnomedied stoneout."
				}
				"stoneout." {
					clear_ticker
					tasklist_add this "elf_action -screen \{300 200 16\}"
					if {[check_callback "harvested1"]} {
						tasklist_add this "elf_action -anim schmollen -speak 1120f"
						tasklist_add this "elf_action -anim reden_a -speak 1120g"
						set othervar false
					} else {
						tasklist_add this "elf_action -anim auffordern -speak 1120d"
						tasklist_add this "task_to_ticker 1001o"
						set othervar true
					}
					set tocheck "gnomedied harvested1"
				}
				"harvested1" {
					if {$othervar} {
						tasklist_add this "elf_action -anim reden_a -speak 1120g"
					}
					tasklist_add this "elf_action -screen \{100 300 16\}"
					tasklist_add this "elf_action -anim reden_b -speak 1120e"
					tasklist_add this "elf_action -wait 3"
					set voodoopoint [obj_query this -class Info_Pos_Zwerg -limit 1 -range 20]
					set_owner $voodoopoint 0
					tasklist_add this "create_trigger $voodoopoint Tut_2015 70"
					set tocheck ".truereturn.."
					clear_ticker
				}
				".truereturn.." {
					soundfile_open 1273a1272n
					prodslot_override normal 31
					set_posx $collbox [expr {[get_posx $collbox]+17}]
					tasklist_add this "elf_action -nearscreen right"
					tasklist_add this "elf_action -screen \{-300 -250 16\}"
					tasklist_add this "elf_action -anim reden_b -speak 1273a"
					ref_set $gnome_ref1 current_worktask ""
					ref_set $gnome_ref2 current_worktask ""
					set comp_val "pack"
					set othervar false
					set tocheck "gnomedied fireselected gnomegotwork"
					tasklist_add this "task_to_ticker 1001p"
				}
				"fireselected" {
					elf unfollowview
					tasklist_add this "elf_action -screen \{500 -150 16\}"
//					tasklist_add this "elf_action -screen none"
					tasklist_add this "elf_action -anim zeigen_rechts -speak 1273b -wait =4"
					set othervar true
					set tocheck "gnomedied gnomegotwork fireplacepacked"
				}
				"gnomegotwork" {
					set_particlesource $fireplace 1 0
					if {$othervar} {
						tasklist_add this "elf_action -screen \{-200 200 16\}"
//						tasklist_add this "elf_action -screen none"
					}
					tasklist_add this "elf_action -anim reden_a -speak 1273c"
					set tocheck "gnomedied fireplacepacked"
					clear_ticker
				}
				"fireplacepacked" {
					tasklist_add this "elf_action -screen \{-200 200 16\}"
					tasklist_add this "elf_action -anim zustimmen -speak 1110a"
					tasklist_add this "elf_action -anim reden_b -speak 1110b"
					tasklist_add this "elf_action -screen \{-200 200 16\}"
					tasklist_add this "elf_action -anim reden_a -speak 1110c"
					tasklist_add this "elf_action -anim reden_b -speak 1280a"
					set tocheck "gnomedied anygnomeselected"
					clear_ticker
					tasklist_add this "task_to_ticker 1001q"
				}
				"anygnomeselected" {
					elf unfollowview
					tasklist_add this "elf_action -screen \{-150 -150 16\}"
//					tasklist_add this "elf_action -screen none"
					tasklist_add this "elf_action -anim reden_a -speak 1280b"
					tasklist_add this "elf_action -anim reden_b -speak 1280c"
					set tocheck "gnomedied anothergnomeselected"
					clear_ticker
					tasklist_add this "task_to_ticker 1001r"
				}
				"anothergnomeselected" {
					tasklist_add this "elf_action -screen \{-150 -150 16\}"
					tasklist_add this "elf_action -anim reden_a -speak 1280d"
					tasklist_add this "elf_action -anim reden_b -speak 1280e"
					tasklist_add this "elf_action -screen \{-150 -150 16\}"
					tasklist_add this "elf_action -anim reden_a -speak 1280h"
					tasklist_add this "elf_action -anim reden_b -speak 1280z"
					tasklist_add this "elf_action -screen \{-150 -150 16\}"
					tasklist_add this "elf_action -anim warnen -speak 1280i"
					tasklist_add this "elf_action -anim koketieren -speak 1280j"
					clear_ticker
					set tocheck "gnomedied truereturn..."
				}
				"truereturn..." {
					set gnome_ref5 [subst \$gnome_ref$comp_val]
					set gnomename5 [subst \$gnomename$comp_val]
					set condition [get_attrib $gnome_ref1 atr_Nutrition]
					set hod [expr int([gethours])%12]
					set condition [expr ($condition<0.7)?1:2]
//					set condition [expr ($condition<0.3&&$hod%3<1)?0:(($condition<0.6)?1:2)]
					log "Zwergcondition: $condition ($hod)"
					set which [expr ($hod/3+$condition*5)%4]
					set comp_val [lindex {{1 1} {2 1} {2 0} {1 0}} $which]
					set gnomename5 [lindex {Ole Trine Trine Ole} $which]
					if {$which==0||$which==3} {set gnome_ref5 $gnome_ref1} {set gnome_ref5 $gnome_ref2}
					set begin [lindex {3 9} [lindex $comp_val 1]]
					set end   [lindex {9 3} [lindex $comp_val 1]]
					tasklist_add this "elf_action -anim auffordern -speak 1110[lindex {e g f d} $which]"
					set tocheck "gnomedied clockchanged"
					clear_ticker
					tasklist_add this "task_to_ticker 1001s"
				}
				"clockchanged" {
					clear_ticker
					tasklist_add this "elf_action -anim zustimmen -speak 1280k"
					if {[check_callback fireplaceunboxed]} {
						set tocheck "gnomedied fireplaceunboxed."
					} else {
						set tocheck "gnomedied clockchanged."
					}
				}
				"clockchanged." {
					if { ! [is_selected $fireplace] } {
						tasklist_add this "elf_action -anim reden_a -speak 1271a"
					}
					tasklist_add this "task_to_ticker 1001t"
					set tocheck "gnomedied fireselected. fireplaceunboxed."
				}
				"nothingselected" {
					// inaktiv
					tasklist_add this "elf_action -screen \{300 250 16\}"
					tasklist_add this "elf_action -wait 1"
					tasklist_add this "elf_action -anim reden_a -speak 1271a"
					set tocheck "gnomedied allinspare fireselected. fireplaceunboxed."
				}
				"fireselected." {
					tasklist_add this "elf_action -anim reden_b -speak 1271b -wait =2"
					tasklist_add this "elf_action -screen \{250 -100 16\}"
					tasklist_add this "elf_action -anim zeigen_links -speak 1271c"
					set tocheck "gnomedied allinspare fireplaceunboxed. .gnomegotwork"
					set comp_val "unpack"
					clear_ticker
					tasklist_add this "task_to_ticker 1001u"
				}
				".gnomegotwork" {
				//	clear_ticker
					tasklist_add this "elf_action -screen \{200 300 16\}"
					set tocheck "gnomedied allinspare fireplaceunboxed."
				}
				"fireplaceunboxed." {
					prodslot_override reset
					tasklist_add this "elf_action -screen \{250 -200 16\}"
					if {[check_callback firedeselected]} {
						tasklist_add this "elf_action -anim reden_b -speak 1272b"
					}
					set tocheck "gnomedied fireselected.."
					clear_ticker
				}
				"fireselected.." {
					tasklist_add this "elf_action -screen \{330 -150 16\}"
					tasklist_add this "elf_action -wait 1"
					tasklist_add this "elf_action -anim reden_b -speak 1272a"
					tasklist_add this "elf_action -anim reden_a -speak 1272c"
					tasklist_add this "elf_action -anim zeigen_links -speak 1272d"
					tasklist_add this "elf_action -screen \{330 -150 16\}"
					tasklist_add this "elf_action -wait 1"
					tasklist_add this "elf_action -anim zeigen_rechts -speak 1272e"
					tasklist_add this "elf_action -anim reden_a -speak 1272p"
					tasklist_add this "elf_action -screen \{330 -150 16\}"
					tasklist_add this "elf_action -anim reden_b -speak 1272f"
					tasklist_add this "elf_action -anim reden_a -speak 1272g"
					set tocheck "gnomedied allinspare anythingclicked prodzeltcnttoohigh prodcntcorrect"
					set correctprodcnt {1 ==1}
					set othervar true
					clear_ticker
					tasklist_add this "task_to_ticker 1001v"
					tasklist_add this {
						prodslot_override disable 0
						prodslot_override disable 1
						prodslot_override disable 3
						prodslot_override disable 4
						prodslot_override disable 5
					}
				}
				"anythingclicked" {
					set_prod_slot_cnt $fireplace Grillpilz 0
					set_prod_slot_cnt $fireplace Grillhamster 0
					set_prod_slot_cnt $fireplace Feuerstelle 0
					set_prod_slot_cnt $fireplace Hauklotz 0
					set_prod_slot_cnt $fireplace Steinmetz 0
					tasklist_add this "elf_action -screen \{400 300 16\}"
					tasklist_add this "elf_action -wait 1"
					tasklist_add this "elf_action -anim warnen -speak 1272o"
					set tocheck [lnand "anythingclicked" $tocheck]
				}
				"allinspare" {
					tasklist_add this "elf_action -anim verzweifeln -speak 1272m"
					lrem tocheck 1
				}
				"prodzeltcnttoohigh" {
					set prodcnt [get_prod_slot_cnt $fireplace Zelt]
					tasklist_add this "elf_action -anim reden_b -speak 1272h"
					tasklist_add this "elf_action -screen \{400 300 16\}"
					tasklist_add this "elf_action -anim warnen -speak 1272i"
					tasklist_add this "elf_action -anim reden_a -speak 1272j"
					set othervar false
					set tocheck "gnomedied prodcntcorrect"
				}
				"prodcntcorrect" {
					if {$othervar} {
						tasklist_add this "elf_action -anim reden_b -speak 1272h"
					}
					tasklist_add this "elf_action -screen \{200 300 16\}"
					set comp_val "walk harvest pickupitem work bringprod"
					set tocheck "gnomedied allinspare gnomegotwork. zeltproduced prodzeltcnttoohigh."
					clear_ticker
				}
				"prodzeltcnttoohigh." {
					tasklist_add this "elf_action -screen \{200 300 16\}"
					tasklist_add this "elf_action -anim warnen -speak 1272i"
					tasklist_add this "elf_action -anim reden_a -speak 1272j"
					set tocheck "gnomedied allinspare gnomegotwork. zeltproduced"
				}
				"gnomegotwork." {
					tasklist_add this "elf_action -screen \{200 300 16\}"
					tasklist_add this "elf_action -anim zustimmen -speak 1272k"
					tasklist_add this "elf_action -anim auffordern -speak 1272l"
					set tocheck "gnomedied zeltproduced"
				}
				"zeltproduced" {
					tasklist_add this "elf_action -screen \{200 300 16\}"
					tasklist_add this "elf_action -anim reden_b -speak 1272n"
					clear_ticker
					set tocheck "gnomedied zeltunboxed"
					tasklist_add this "task_to_ticker 1001w"
				}
				"zeltunboxed" {
					clear_ticker
					set standardview "[lrange [get_pos $fireplace] 0 1] 1.5 -0.2 -0.1"
					tasklist_add this "cameracorrection 10 1 1 0"
					set tocheck "zeltunboxed."
				}
				"zeltunboxed." {
					sel /obj
					set gnome_ref3 [new Zwerg "" [concat [lrange [vector_add $mypos {1 0 2}] 0 1] 12] {0 1.57 0}]
					call_method $gnome_ref3 Editor_Set_Info {{gender male} {name Erik}}
					set_owner $gnome_ref3 0
					set_physic $gnome_ref3 false
					set_autolight $gnome_ref3 true
					call_method $gnome_ref3 disable_reprod
					set gnome_ref4 [new Zwerg "" [concat [lrange [vector_add $mypos {-1 0 2}] 0 1] 12] {0 1.57 0}]
					call_method $gnome_ref4 Editor_Set_Info {{gender female} {name Frida}}
					set_owner $gnome_ref4 0
					set_physic $gnome_ref4 false
					set_autolight $gnome_ref4 true
					call_method $gnome_ref4 disable_reprod
					if {[get_attrib $gnome_ref1 atr_Nutrition]+[get_attrib $gnome_ref2 atr_Nutrition]>1.0} {
						set othervar 0.1
					} else {
						set othervar -0.1
					}
					set_attrib $gnome_ref3 atr_Nutrition [expr 0.8-$othervar]
					set_attrib $gnome_ref3 atr_Alertness [expr 0.8-$othervar]
					set_attrib $gnome_ref3 atr_Mood [expr 0.8-$othervar]
					set_attrib $gnome_ref4 atr_Nutrition [expr 0.8-$othervar]
					set_attrib $gnome_ref4 atr_Alertness [expr 0.8-$othervar]
					set_attrib $gnome_ref4 atr_Mood [expr 0.8-$othervar]
					call_method $gnome_ref3 init
					call_method $gnome_ref4 init
					set tocheck "truereturn...."
				}
				"truereturn...." {
					viewlock 0
					set gnomename3 [get_objname $gnome_ref3]
					set gnomegender3 [get_objgender $gnome_ref3]
					set gnomename4 [get_objname $gnome_ref4]
					set gnomegender4 [get_objgender $gnome_ref4]
					if {$gnomegender3==$gnomegender1} {
						set_worktime $gnome_ref3 [expr (int([get_worktime $gnome_ref1 start])+6)%12] 6.0
						set_worktime $gnome_ref4 [expr (int([get_worktime $gnome_ref2 start])+6)%12] 6.0
					} else {
						set_worktime $gnome_ref3 [expr (int([get_worktime $gnome_ref2 start])+6)%12] 6.0
						set_worktime $gnome_ref4 [expr (int([get_worktime $gnome_ref1 start])+6)%12] 6.0
					}
				//	set muetze [call_method $gnome_ref1 get_nameofmuetze "sparetime"]
					call_method $gnome_ref3 create_muetze Dummy_Muetze_a
					call_method $gnome_ref4 create_muetze Dummy_Muetze_b
				//	call_method $gnome_ref3 change_muetze "sparetime"
				//	call_method $gnome_ref4 change_muetze "sparetime"
					create_trigger $gnome_ref3 "Tut_2020"
					set tocheck ".truereturn...."
				}
				".truereturn...." {
					soundfile_open 2020d1330w
					prodslot_override normal 0
					tasklist_add this "elf_action -nearscreen left"
					tasklist_add this "elf_action -screen \{200 -300 16\}"
					tasklist_add this "elf_action -anim reden_a -speak 2020d"
					tasklist_add this "elf_action -anim reden_b -speak 1310a"
					set correctprodcnt {0 >=3}
					set tocheck "gnomedied prodcntcorrect. firedeselected fireselected..."
					clear_ticker
					tasklist_add this "task_to_ticker 1001x"
				}
				"firedeselected" {
					tasklist_add this "elf_action -screen \{200 -300 16\}"
					tasklist_add this "elf_action -anim reden_a -speak 1310b"
					set tocheck "gnomedied prodcntcorrect. fireselected..."
				}
				"fireselected..." {
					tasklist_add this "elf_action -screen \{250 -120 16\}"
					tasklist_add this "elf_action -anim reden_a -speak 1310c"
					set tocheck "gnomedied prodcntcorrect."
				}
				"prodcntcorrect." {
					tasklist_add this "elf_action -screen \{-300 -300 16\}"
					tasklist_add this "elf_action -anim zustimmen -speak 1310d"
					tasklist_add this "elf_action -anim reden_b -speak 1310e"
					tasklist_add this "elf_action -anim reden_a -speak 2020e"
					tasklist_add this "elf_action -screen \{-250 250 16\}"
					tasklist_add this "elf_action -wait 1"
					tasklist_add this "elf_action -anim reden_b -speak 1330a"
					set tocheck "gnomedied anygnomeselected."
					clear_ticker
					tasklist_add this "task_to_ticker 1001q"
				}
				"anygnomeselected." {
					tasklist_add this "elf_action -screen \{-200 150 16\}"
					tasklist_add this "elf_action -wait 1"
					tasklist_add this "elf_action -anim zeigen_rechts -speak 1330b"
					tasklist_add this "elf_action -screen \{-200 150 16\}"
					tasklist_add this "elf_action -anim reden_a -speak 1330c"
					tasklist_add this "elf_action -screen \{-250 300 16\}"
					tasklist_add this "elf_action -anim reden_b -speak 1330d"
					tasklist_add this "elf_action -screen \{-300 300 16\}"
					set gl {}
					set ct [gettime]
					for {set i 1} {$i<5} {incr i} {
						set g [subst \$gnome_ref$i]
						if {[get_worktime $g nextend]<$ct+100||[get_worktime $g lastend]>$ct-100} {
							lappend gl [list $g [expr {(1.0-[get_attrib $g atr_Nutrition])*2}] $i]
						} else {
							lappend gl [list $g [expr {1.0-[get_attrib $g atr_Nutrition]}] $i]
						}
					}
					set comp_val [lindex [lsort -real -decreasing -index 1 $gl] 0]
					set which [lindex $comp_val 2]
					incr which -1
					log "($comp_val) $which ([lsort -real -decreasing -index 1 $gl])"
					tasklist_add this "elf_action -anim reden_b -speak 1330[lindex {e f g h} $which]"
					set comp_val [lindex $comp_val 0]
					set tree [vector_add $mypos {-30.1 -15.1 -2.5}]
					set othervar {log -----[vector_abs [vector_sub $tree [elf get_pos]]]; if {[vector_abs [vector_sub $tree [elf get_pos]]]>1} {tasklist_addfront this "elf move \{$tree\}"} }
					tasklist_add this $othervar
					tasklist_add this "elf_action -wait 3"
					tasklist_add this "elf sleep;log elfsleepnow"
					set othervar [get_attrib $comp_val atr_Nutrition]
					lappend comp_val [call_method $comp_val get_eat_count]
					set tocheck "gnomedied gnomeneartodeath gnomehaseaten timeover100"
					clear_ticker
					tasklist_add this "task_to_ticker 1002[lindex {o p q r} $which]"
				}
				"timeover100" {
					tasklist_add this "elf_action -screen \{-200 300 16\}"
					tasklist_add this "elf_action -wait 3"
					tasklist_add this "elf_action -anim reden_a -speak 1330i"
					set tocheck [lreplace $tocheck end end]
				}
				"gnomeneartodeath" {
					for {set i 1} {$i<5} {incr i} {
						if {[subst \$gnome_ref$i]==$try_increase} {
							set which [expr {$i-1}]
							break
						}
					}
					set gnomename5 [get_objname $try_increase]
					set gnomegender5 [get_objgender $try_increase]
					tasklist_add this "elf_action -screen \{-200 300 16\}"
					tasklist_add this "elf_action -anim verzweifeln -speak 1330[lindex {o p q r} $which]"
					tasklist_add this "elf_action -screen \{-300 300 16\}"
					if {[get_remaining_sparetime $try_increase]} {
						if {[llength [obj_query $fireplace "-class Grillpilz -range 100"]]<3} {
							tasklist_add this "elf_action -anim warnen -speak 1330t"
						} else {
							tasklist_add this "elf_action -anim warnen -speak 1330v"
						}
					} else {
						if {[llength [obj_query $fireplace "-class Grillpilz -range 100"]]<3} {
							tasklist_add this "elf_action -anim warnen -speak 1330u"
						} else {
							tasklist_add this "elf_action -anim warnen -speak 1330s"
						}
					}
					tasklist_add this "elf_action -screen \{-250 250 16\}"
					tasklist_add this "elf_action -anim reden_a -speak 1330w"
					lrem tocheck 1
				}
				"gnomehaseaten" {
					soundfile_open 1260a2040i
					clear_ticker
					set standardview "[lrange [get_pos $door] 0 1] 1.8 -0.2 -0.3"
					set releaseaftercorrection 0
					tasklist_add this "elf_action -screen \{200 300 16\}"
					tasklist_add this "elf_action -wait 1"
					tasklist_add this "elf_action -anim salto -speak 1260a"
					tasklist_add this "elf move \{[get_posx $door] [get_posy this] 16\}"
					tasklist_add this "cameracorrection 1 0.2 0.2"
					tasklist_add this "set_view [lrange [vector_add [get_pos $door] {-5 0 0}] 0 1] 2.3 -0.2 0.4 1"
					tasklist_add this "elf_action -screen \{-240 276 17\}"
					tasklist_add this "call_method $door oeffnen $reference -1"
					tasklist_add this "elf_action -wait 1"
					tasklist_add this "elf_action -anim zeigen_links -speak 1260b"
					set tocheck "gnomedied truereturn....."
				}
				"truereturn....." {
					set standardview "[lrange [vector_add [get_pos $door] {-12 0 0}] 0 1] 3.0 -0.2 -0.3"
					tasklist_add this "cameracorrection 1 0.2 0.2 0"
					tasklist_add this "elf_action -screen \{-400 300 25\}"
					tasklist_add this "elf_action -wait 3"
					tasklist_add this "elf_action -anim zeigen_rechts -speak 1260c"
					tasklist_add this "elf_action -wait 1"
					tasklist_add this "elf_action -anim zeigen_links -speak 1260d"
					tasklist_add this "set_sequenceactive this 0"
					if {[get_selectedobject]} {
						tasklist_add this "elf_action -anim reden_b -speak 1260e"
						tasklist_add this "task_to_ticker 1002a"
					}
					set_owner_attrib 0 digenable0 1
					set tocheck "gnomedied nothingselected."
				}
				"nothingselected." {
					clear_ticker
					set releaseaftercorrection 1
					tasklist_add this "cameracorrection 2 0.5 0.3"
					tasklist_add this "elf_action -screen \{200 -120 23\}"
					tasklist_add this "elf_action -wait 1"
					tasklist_add this "elf_action -anim reden_a -speak 1260f"
					tasklist_add this "elf_action -screen \{200 -120 22\}"
					tasklist_add this "elf_action -wait 1"
					tasklist_add this "elf_action -anim reden_b -speak 1260g"
					tasklist_add this "elf_action -screen \{200 -120 20\}"
					tasklist_add this "elf_action -wait 1"
					tasklist_add this "elf_action -anim reden_a -speak 1260h"
					tasklist_add this "elf_action -screen \{-400 300 18\}"
					tasklist_add this "task_to_ticker 1002b"
					set tocheck "gnomedied notmarked markedcorrect markmoreright markmoreleft tunneldigged markedhigh"
					set digwatch1 $digwatchright
					set digdest1 $rightdig
					set digwatch2 $digwatchleft
					set digdest2 [vector_add $leftdig {1 -0.3 0}]
					set comp_val $digdest2
				}
				"notmarked" {}
				"markmoreright" {
					tasklist_add this "cameracorrection 4 0.8 0.5"
					tasklist_add this "elf_action -screen \{-300 200 17\}"
					tasklist_add this "elf_action -wait 1"
					tasklist_add this "elf_action -anim reden_b -speak 1260j"
					set tocheck "gnomedied markedcorrect markmoreleft tunneldigged markedhigh"
				}
				"markmoreleft" {
					tasklist_add this "cameracorrection 4 0.8 0.5"
					tasklist_add this "elf_action -screen \{300 200 17\}"
					tasklist_add this "elf_action -wait 1"
					tasklist_add this "elf_action -anim reden_b -speak 1260i"
					set tocheck "gnomedied markedcorrect tunneldigged markedhigh"
				}
				"markedcorrect" {
					clear_ticker
					viewlock 0
					tasklist_add this "elf_action -screen \{-300 250 16\}"
					tasklist_add this "elf_action -wait 1"
					tasklist_add this "elf_action -anim zustimmen -speak 1260k"
					tasklist_add this "task_to_ticker 1002c"
					set tocheck "gnomedied tunneldigged markedhigh"
				}
				"tunneldigged" {
					clear_ticker
					delete_wrong_mark
					set taken 0
					foreach i $stones {
						if {[obj_valid $i]} {
							set_lock $i 0
						}
						if {[get_posx $i]>[get_posx $door]-5} {
							set taken 1
						}
					}
					set releaseaftercorrection 0
					set standardview "[lrange [vector_add [get_pos $door] {-12 -0.5 0}] 0 1] 1.2 0.0 -0.3"
					tasklist_add this "cameracorrection 3 0.6 0.5"
					tasklist_add this "elf_action -screen \{400 250 16\}"
					tasklist_add this "elf_action -wait 1"
					if {$taken} {
						tasklist_add this "elf_action -anim reden_a -speak 2019c"
					} else {
						tasklist_add this "elf_action -anim reden_a -speak 2019b"
					}
					tasklist_add this "elf_action -anim reden_b -speak 2019d"
					tasklist_add this "elf_action -screen \{400 250 16\}"
					tasklist_add this "elf_action -anim reden_b -speak 2019e"
					tasklist_add this "elf_action -anim reden_a -speak 2019f"
					tasklist_add this "set standardview \{[lrange [vector_add [get_pos $door] {-12 -2 0}] 0 1] 2.1 -0.1 -0.1\}"
					tasklist_add this "set releaseaftercorrection 1"
					tasklist_add this "cameracorrection 1 0.2 0.1 0"
					tasklist_add this "task_to_ticker 1002d"
					set tocheck "gnomedied cavemarked stonesfree"
					set digwatch1 $digwatchup
					set comp_val $cavedigy
					set stones [obj_query $door "-class Stein -range 50 -flagneg contained"]
					set_owner_attrib 0 digenable0 0
					set_owner_attrib 0 digenable1 1
				}
				"markedhigh" {
					incr wait_increase
					delete_wrong_mark
				}
				"cavemarked" {
					clear_ticker
					set tocheck "gnomedied stonesfree cavedeleted"
					tasklist_add this "elf_action -screen \{-300 200 16\}"
					tasklist_add this "elf_action -wait 1"
					tasklist_add this "elf_action -anim reden_b -speak 2019g"
					tasklist_add this "task_to_ticker 1002e"
				}
				"cavedeleted" {
					clear_ticker
					tasklist_add this "elf_action -screen \{-300 200 16\}"
					tasklist_add this "elf_action -wait 2"
					tasklist_add this "elf_action -anim reden_b -speak 2019f"
					tasklist_add this "task_to_ticker 1002d"
					set tocheck "gnomedied cavemarked stonesfree"
				}
				"stonesfree" {
					clear_ticker
					if {"false"==[check_callback notmarked]} {
						tasklist_add this "elf_action -screen \{-300 300 16\}"
						tasklist_add this "elf_action -anim reden_b -speak 2019h"
						tasklist_add this "elf_action -anim reden_a -speak 2019i"
						tasklist_add this "task_to_ticker 1002f"
					}
					set tocheck "gnomedied notmarked."
				}
				"notmarked." {
					clear_ticker
					set standardview "[lrange [get_pos $fireplace] 0 1] 1.5 -0.2 0.0"
					set releaseaftercorrection 1
					tasklist_add this "cameracorrection 3 0.7 0.5"
					tasklist_add this "elf_action -screen \{200 200 16\}"
					tasklist_add this "elf_action -wait 1"
					if {![is_selected $fireplace]} {
						tasklist_add this "elf_action -anim auffordern -speak 1335a"
						tasklist_add this "task_to_ticker 1002g"
					}
					set othervar 0
					set tocheck "gnomedied fireselected.... firedeselected."
					set_owner_attrib 0 digenable0 1
					set stonelist {}
					foreach gnome "$gnome_ref1 $gnome_ref2 $gnome_ref3 $gnome_ref4" {
						lappend stonelist [list $gnome [get_attrib $gnome exp_Stein]]
					}
					set gnome [lindex [lsort -index 1 -real -decreasing $stonelist] 0]
					if {[lindex $gnome 1]<0.025} {set_attrib [lindex $gnome 0] exp_Stein 0.031}
					prodslot_override reset
				}
				"firedeselected." {
					clear_ticker
					tasklist_add this "cameracorrection 3 0.8 0.5"
					tasklist_add this "elf_action -screen \{250 -150 16\}"
					tasklist_add this "elf_action -wait 1"
					tasklist_add this "elf_action -anim auffordern -speak 1335a"
					tasklist_add this "task_to_ticker 1002g"
					set tocheck "gnomedied fireselected...."
				}
				"fireselected...." {
					clear_ticker
					set_prod_slot_cnt $fireplace Feuerstelle 0
					set_prod_slot_cnt $fireplace Hauklotz 0
					set_prod_slot_cnt $fireplace Steinmetz 0
					if {$othervar<3} {
						tasklist_add this "elf_action -screen \{250 -150 16\}"
						tasklist_add this "elf_action -anim reden_[lindex {b a} [expr $othervar%2]] -speak 1335[lindex {b c d} $othervar]"
						if {$othervar<2} {
							incr othervar
							set tocheck "fireselected.... firedeselected."
						} else {
							tasklist_add this "elf_action -screen \{200 -200 16\}"
							tasklist_add this "elf_action -anim reden_a -speak 1335e"
							set tocheck ".truereturn....."
						}
					}
				}
				".truereturn....." {
					prodslot_override disable 3
					prodslot_override disable 5
					prodslot_override disable 4
					set_prod_slot_cnt $fireplace Feuerstelle 0
					set_prod_slot_cnt $fireplace Hauklotz 0
					set_prod_slot_cnt $fireplace Steinmetz 0
					sel /obj
					set seq [new Sequence_triggered "" [vector_add [get_pos $door2] {7 0 -4}] {0 0 0}]
					trigger create $seq callback "sequencer_activate"
					trigger set_callback $seq {expr 1}
					trigger set_checktimer $seq 1
					set gnomelist [obj_query $seq -class Zwerg -range 7 -cloaked 1]
					if {$gnomelist==0} {
						call_method $seq set_sequencescript Tut_2021
					} else {
						call_method $seq set_sequencescript Tut_2022
						call_method $seq preset_actors $gnomelist
					}
					set_sequenceactive this 0
					tasklist_add this "waittime 2"
					tasklist_add this "soundfile_open 2025g2040g"
					tasklist_add this "task_to_ticker 1002n"
					set tocheck "gnomedied stoneset stonesetwrong"
				}
				"stonesetwrong" {
					tasklist_add this "elf_action -screen \{200 -200 16\}"
					tasklist_add this "elf_action -wait 1"
					tasklist_add this "elf_action -anim verzweifeln -speak 2025g"
					set tocheck "gnomedied stoneset stonepacked"
				}
				"stonepacked" {
					set tocheck "gnomedied stoneset stonesetwrong"
				}
				"stoneset" {
					clear_ticker
					set releaseaftercorrection 0
					set standardview "[lrange [vector_add [get_pos $door] {-39 0 0}] 0 1] 1.8 -0.2 -0.4"
					tasklist_add this "cameracorrection 2 0.5 0.5"
					tasklist_add this "elf_action -wait 1"
					tasklist_add this "elf_action -screen \{-400 300 16\}"
					tasklist_add this "call_method $door2 oeffnen [obj_query $door2 -class Grenzstein -range 30 -limit 1] -1"
					tasklist_add this "elf_action -wait 3"
					tasklist_add this "elf_action -anim zeigen_links -speak 2018a"
					tasklist_add this "elf_action -anim reden_a -speak 2018b"
					tasklist_add this "viewlock 0;set_sequenceactive this 0;set releaseaftercorrection 1"
					tasklist_add this "task_to_ticker 1002h"
					set tocheck "gnomedied markedcorrect. tunneldigged."
					set digwatch1 $digwatchleft
					set digwatch2 $digwatchlow
					set digdest1 $upperdig
					set digdest2 $lowerdig
					set comp_val $digdest2
				}
				"markedcorrect." {
					clear_ticker
					tasklist_add this "elf_action -screen \{-300 -200 16\}"
					tasklist_add this "elf_action -wait 1"
					tasklist_add this "elf_action -anim reden_b -speak 2018c"
					tasklist_add this "task_to_ticker 1002i"
					set tocheck "gnomedied tunneldigged."
				}
				"tunneldigged." {
					clear_ticker
					set standardview "[lrange $comp_val 0 1] 1.5 -0.2 -0.2"
					set releaseaftercorrection 1
					tasklist_add this "cameracorrection 2 0.5 0.5"
					tasklist_add this "elf_action -screen \{-200 300 16\}"
					tasklist_add this "elf_action -wait 1"
					tasklist_add this "elf_action -anim reden_b -speak 2018d"
					tasklist_add this "elf_action -screen \{-200 300 16\}"
					tasklist_add this "elf_action -anim reden_a -speak 2018e"
					tasklist_add this "task_to_ticker 1002j"
					set walktarget $puppet1
					set tocheck "gnomedied gnomenearpuppet"
				}
				"gnomenearpuppet" {
					clear_ticker
					set standardview "[lrange [vector_add [get_pos $walktarget] {-4.43 -2.34 0}] 0 1] 1.8 -0.2 0.5"
					tasklist_add this "cameracorrection 3 0.7 0.8"
					tasklist_add this "elf_action -nearscreen left"
					tasklist_add this "elf_action -screen \{300 250 16\}"
					tasklist_add this "elf_action -wait 1"
					tasklist_add this "elf_action -anim reden_b -speak 2040a"
					tasklist_add this "elf_action -anim reden_a -speak 2040b"
					tasklist_add this "elf_action -screen \{300 250 16\}"
					tasklist_add this "elf_action -wait 1"
					tasklist_add this "elf_action -anim reden_b -speak 2040c"
					tasklist_add this "elf_action -anim reden_a -speak 2040m"
					tasklist_add this "elf_action -screen \{300 250 16\}"
					tasklist_add this "elf_action -wait 1"
					tasklist_add this "elf_action -anim reden_b -speak 2040n"
					tasklist_add this "elf_action -anim reden_a -speak 2040o"
					tasklist_add this "elf_action -anim auffordern -speak 2040p"
					tasklist_add this "task_to_ticker 1002k"
					set tocheck "gnomedied gnomehurt gnomeexper"
					set try_increase 0.005
					set comp_val [list 0]
					for {set i 1} {$i<5} {incr i} {
						lappend comp_val [get_attrib [subst \$gnome_ref$i] atr_Hitpoints]
					}
				}
				"gnomehurt" {
					tasklist_add this "elf_action -screen \{400 250 16\}"
					tasklist_add this "elf_action -wait 1"
					tasklist_add this "elf_action -anim reden_b -speak 2040d"
					tasklist_add this "elf_action -anim reden_a -speak 2040e"
					tasklist_add this "elf_action -anim reden_b -speak 2040f"
					set tocheck "gnomedied gnomeexper"
				}
				"gnomeexper" {
					clear_ticker
					tasklist_add this "elf_action -screen \{-350 250 16\}"
					tasklist_add this "elf_action -wait 1"
					tasklist_add this "elf_action -anim reden_a -speak 2040g"
					//tasklist_add this "elf_action -anim reden_b -speak 2040h"
					tasklist_add this "task_to_ticker 1002l"
					set tocheck "gnomedied gnomeexper."
					set try_increase 0.02
				}
				"gnomeexper." {
					clear_ticker
					set_hoverable $walktarget 0
					foreach othervar [obj_query this -pos [get_pos $walktarget] -class Holzpuppe -range 20] {
						set_hoverable $othervar 0
					}
					foreach gnome "$gnome_ref1 $gnome_ref2 $gnome_ref3 $gnome_ref4" {
						if {[state_get $gnome]=="fight_dispatch"} {
							timer_event $gnome evt_zwerg_break -attime [expr {[gettime]+0.2}]
						}
					}
					//tasklist_add this "elf_action -screen \{-300 200 16\}"
					//tasklist_add this "elf_action -wait 1"
					//tasklist_add this "elf_action -anim warnen -speak 2040i"
					//tasklist_add this "elf_action -anim auffordern -speak 2040j"
					//tasklist_add this "task_to_ticker 1002m"
					//set othervar {if {[vector_abs [vector_sub $tree [elf get_pos]]]>1} {tasklist_addfront this "elf move \{$tree\}"} }
					//tasklist_add this $othervar
					//tasklist_add this "elf_action -wait 3"
					//tasklist_add this "elf sleep"
					set tocheck "truereturn......"
				}
				"truereturn......" {
					set gnomelist [obj_query $puppet1 -class Zwerg -boundingbox {-4 -2 -10 4 2 10} -cloaked 1]
					sel /obj
					set seq [new Sequence_triggered "" [get_pos $puppet1] {0 0 0}]
					call_method $seq set_sequencescript tut_2500
					trigger create $seq any_object "sequencer_activate"
					trigger set_target_class $seq Zwerg
					trigger set_target_owner $seq 0
					trigger set_target_range $seq 5
					set_sequenceactive this 0
					if {[llength $gnomelist]>1} {
						call_method $seq set_vars {beam 0}
					} else {
						call_method $seq set_vars {beam 1}
					}
					tasklist_add this "waittime 2"
					set tocheck ".truereturn......"
				}
				".truereturn......" {
					set judgelist [list]
					set comp_val [list]
					set othervar [list]
					set tutorial 1
					self_destroy
					return
					foreach gnome "$gnome_ref1 $gnome_ref2 $gnome_ref3 $gnome_ref4" {
						set value 1
						foreach atr {atr_Hitpoints atr_Hitpoints atr_Nutrition atr_Alertness atr_Mood} {
							set value [expr {$value * [get_attrib $gnome $atr]}]
						}
						foreach atr {exp_Stein exp_Holz exp_Nahrung exp_Kampf exp_Kampf} {
							fincr value [expr {[get_attrib $gnome $atr]*3}]
						}
						log "[get_objname $gnome]: $value"
						lappend judgelist [list $gnome $value]
					}
					sel /obj
					set seq [new Sequence_triggered "" $mypos {0 0 0}]
					call_method $seq set_sequencescript TutorialEnd
					trigger create $seq callback "sequencer_activate"
					trigger set_callback $seq {expr 1}
					trigger set_checktimer $seq 1
					set gnomelist [list]
					foreach entry [lsort -index 1 -decreasing $judgelist] {
						lappend gnomelist [lindex $entry 0]
					}
					if {[get_objgender [lindex $gnomelist 0]]==[get_objgender [lindex $gnomelist 1]]} {
						set sec [lindex $gnomelist 1]
						lrem gnomelist 1
						lappend gnomelist $sec
					}
					call_method $seq preset_actors $gnomelist
					set_sequenceactive this 0
					tasklist_add this "waittime 2"
					tasklist_add this "self_destroy"
				}
			}
			if {$possibility!="markedhigh"} {state_triggerfresh this task}
		} else {
			incr wait_increase
			state_disable this
			action this wait 1 {state_enable this}
		}
	}
	obj_init {
		set_selectable this 0
		set_hoverable this 0
		call scripts/misc/info_obj.tcl
		set player_task_progress 0
		set nt_id ""
		set try_increase 0
		set reference [get_ref this]
		set comp_val "0 0"
		set special_case ""
		set gnome_ref1 0; set gnome_ref2 0; set gnome_ref3 0; set gnome_ref4 0
		set gnomename1 "" ; set gnomename2 "" ; set gnomename3 "" ; set gnomename4 ""
		set gnomegender1 "" ; set gnomegender2 "" ; set gnomegender3 "" ; set gnomegender4 ""
		set tocheck "truereturn"
		set othervar ""
		set wait_increase 0
		set releaseaftercorrection 1
		set correctioncount 0
		set tutorial 1
		set current_soundfile ""
//		set walktarget 0
//		set tree [vector_add [get_pos [lindex [lsort -int [obj_query this {-class Dummy_Obw_baum_g -range 200}]] 0]] {-4.4 -13.9 7.0}]
//		set stones [obj_query this "-class Stein -range 200 -limit 5"]
		state_trigger this checking
		state_disable this
		proc check_callback {player_task_progress} {
			global comp_val try_increase wait_increase remote_var correctprodcnt door othervar coal
			global gnome_ref1 gnome_ref2 gnome_ref3 gnome_ref4 fireplace walktarget stones mypos
			switch [string trim $player_task_progress "."] {
				"truereturn" { return true }
				"gnomedied" {
					for {set i 1} {$i<5} {incr i} {
						if {[subst \$gnome_ref$i]} {
							if {![obj_valid [subst \$gnome_ref$i]]} {
								return true
							}
						}
					}
					return false
				}
				"gnomereached" {
					if {[vector_dist [elf get_pos] [get_pos $gnome_ref1]]<11} {return true} {return false}
				}
				"perspective" { if {$try_increase>2} { set try_increase 0 ; return true
					} else {
						set cur_val [lrange [get_view] 3 4]
						if {abs([lindex $cur_val 0]-[lindex $comp_val 0])>0.01||abs([lindex $cur_val 1]-[lindex $comp_val 1])>0.01} {
							set comp_val $cur_val
							incr try_increase
						}
						return false
				}	}
				"zoom" { if {$try_increase>1} { set try_increase 0 ; return true
					} else {
						set cur_val [lindex [get_view] 2]
						if {abs($cur_val-$comp_val)>0.1} {
							set comp_val $cur_val
							incr try_increase
						}
						return false
				}	}
				"viewtarget" { if {$try_increase>3} { set try_increase 0 ; return true
					} else {
						set cur_val [lrange [get_view] 0 1]
						if {abs([lindex $cur_val 0]-[lindex $comp_val 0])>0.1||abs([lindex $cur_val 1]-[lindex $comp_val 1])>0.1} {
							set comp_val $cur_val
							incr try_increase
						}
						return false
				}	}
				"beforeselecting" { return true }
				"gnome1selected" { if {[is_selected $gnome_ref1]} { return true } else { return false } }
				"gnome1deselected" { if {[is_selected $gnome_ref1]} { return false } else { return true } }
				"wronglydeselected" { if {$wait_increase>5||[is_selected $gnome_ref1]} { return false } else { return true } }
				"gnomehaswalked" {
					if {$try_increase>5} {return true}
					set cur_val [get_pos $gnome_ref1]
					if {[vector_abs [vector_sub $cur_val $comp_val]]>0.5} {
						set comp_val $cur_val
						incr try_increase
					}
					return false
				}
				"gnomewalkedright" {
					set cur_val [vector_dist [get_pos $gnome_ref1] $walktarget]
					if {$cur_val<3} {return true}
					if {$cur_val<$comp_val} {set comp_val $cur_val ; set wait_increase 0}
					return false
				}
				"gnomewalkedwrong" { if {[vector_dist [get_pos $gnome_ref1] $walktarget]>$comp_val+5} {return true} {return false} }
				"stonein" { if { [inv_find $gnome_ref1 "Kohle"]!=-1 } { return true } { return false } }
				"stoneout" { if { [is_contained $coal] } { return false } { return true } }
				"gnomenearelf" { if {[vector_dist [elf get_pos] [get_pos $gnome_ref1]]<5} {return true} {return false} }
				"remotevartrue" {  if {$remote_var} { return true } { return false }  }
				"fireplaceininv" { if { [is_contained $fireplace] } { return true } {return false } }
				"fireplaceonmouse" { if {[get_place_info]=="1 0 0"} {return true} {return false} }
				"fireplacegreen" { if {[get_place_info]=="1 1 0"} {return true} {return false} }
				"fireplacebox" { if {[get_place_info]=="1 1 1"} {return true} {return false} }
				"fireplacewrong" {
					if {[get_boxed $fireplace]&&![is_contained $fireplace]} { return true } { return false }
				}
				"fireplaceunbuilt" { if {[get_boxed $fireplace]==0&&[get_buildupstate $fireplace]==0} {return true} {return false} }
				"fireplaceunpacked" { if {![is_contained $fireplace]} {
					if {[get_buildupstate $fireplace]&&[vector_dist [get_pos $fireplace] [get_pos [obj_query $fireplace "-class Pilz -range 100 -limit 1"]]]<=10} {
						return true } }
					return false
				}
				"harvested1" { if {[obj_query $fireplace "-class Pilzstamm -limit 1 -range 100"]} {return true} {return false} }
				"fireselected" { if {[is_selected $fireplace]} {return true} {return false} }
				"gnomegotwork" {
					for {set i 1} {$i<5} {incr i} {
						if {[subst \$gnome_ref$i]} {
							if {-1!=[lsearch $comp_val [ref_get [subst \$gnome_ref$i] current_worktask]]} {return true}
						}
					}
					return false
				}
				"fireplacepacked" { if {[get_boxed $fireplace]} {return true} {return false} }
				"anygnomeselected" {
					for {set i 1} {$i<5} {incr i} {
						if {[subst \$gnome_ref$i]} {
							if {[is_selected [subst \$gnome_ref$i]]} {
								set comp_val $i
								return true
							}
						}
					}
					return false
				}
				"anothergnomeselected" {
					for {set i 1} {$i<5} {incr i} {
						if {[subst \$gnome_ref$i]&&$i!=$comp_val} {
							if {[is_selected [subst \$gnome_ref$i]]} {
								set comp_val $i
								return true
							}
						}
					}
					return false
				}
				"clockchanged" {
					global gnome_ref5 begin
					if {abs([get_worktime $gnome_ref5 start]-$begin)>0.1} {return false}
					if {abs([get_worktime $gnome_ref5 duration]-6.0)>0.1} {return false}
					return true
				}
				"fireplaceunboxed" { if { [get_buildupstate $fireplace] } { return true } { return false } }
				"firedeselected" { if {[is_selected $fireplace]} {return false} {return true} }
				"anythingclicked" {
					foreach item {Grillpilz Grillhamster Feuerstelle Hauklotz Steinmetz} {
						if {[get_prod_slot_cnt $fireplace $item]} {
							return true
						}
					}
					return false
				}
				"prodcntcorrect" {
					set prodlist {Grillpilz Zelt Hauklotz Steinmetz Feuerstelle}
					if "[get_prod_slot_cnt $fireplace [lindex $prodlist [lindex $correctprodcnt 0]]][lindex $correctprodcnt 1]" {
						return true	} else { return false
					}
				}
				"prodzeltcnttoohigh" { if {[get_prod_slot_cnt $fireplace Zelt]>1} {
					if {[obj_query $fireplace -class Zelt -range 20 -limit 1]} {
						return false } else {return true}
						} else {return false} }
				"allinspare" {
					for {set i 1} {$i<5} {incr i} {
						if {[subst \$gnome_ref$i]} {
							if {[get_remaining_sparetime [subst \$gnome_ref$i]]==0} {return false}
							log "Gnome $i ([subst \$gnome_ref$i]) is in Spare"
						}
					}
					return true
				}
				"zeltproduced" { if {[obj_query $fireplace "-class Zelt -range 15 -limit 1"]} {return true} {return false} }
				"zeltunboxed" {
					if {[set zelt [obj_query $fireplace "-class Zelt -range 40 -flagneg boxed -limit 1"]]} {
						if {[get_buildupstate $zelt]} {return true}
					}
					return false
				}
				"gnomehaseaten" {
					set g [lindex $comp_val 0]
					set old [lindex $comp_val 1]
					set eatencount [expr {[call_method $g get_eat_count]-$old}]
					if {$eatencount>1} {
						return true
					}
					return false
				}
				"timeover100" { if { $wait_increase>50 } { return true } { return false } }
				"gnomeneartodeath" {
					for {set i 1} {$i<5} {incr i} {
						if {[get_attrib [subst \$gnome_ref$i] atr_Hitpoints]<0.8} {set try_increase [subst \$gnome_ref$i];return true}
					}
					return false
				}
				"nothingselected" { if {[get_selectedobject]} {return false} {return true} }
				"notmarked" {
					global digwatch1
					if {"-1.0 -1.0 1.0"==[dig_next $digwatch1 $gnome_ref1]} {
						return true
					}
					return false
				}
				"markmoreright" { if {$wait_increase<10} {return false}
					global digwatch1 digdest1
					log "right: ($digwatch1) ($digdest1) ([dig_next $digwatch1 $gnome_ref1])"
					if {[vector_dist [dig_next $digwatch1 $gnome_ref1] $digdest1]>0.9} {
						log "true";return true} {set wait_increase 19;log "false";return false} }
				"markmoreleft" { if {$wait_increase<20} {return false}
					global digwatch2 digdest2
					log "left: ($digwatch2) ($digdest2) ([dig_next $digwatch2 $gnome_ref1])"
					if {[vector_dist [dig_next $digwatch2 $gnome_ref1] $digdest2]>0.9} {
						log "true";return true} {log "false";return false} }
				"markedcorrect" {
					global digwatch1 digdest1 digwatch2 digdest2
					if {[vector_dist [dig_next $digwatch1 $gnome_ref1] $digdest1]>0.9} {return false}
					if {[vector_dist [dig_next $digwatch2 $gnome_ref1] $digdest2]>0.9} {return false}
					return true }
				"tunneldigged" {
					global digwatch2
					if {[get_hmap [lindex $comp_val 0] [lindex $comp_val 1]]<12&&[dig_next $digwatch2 $gnome_ref1]=="-1.0 -1.0 1.0"} {return true} {return false} }
				"markedhigh" { return true }
				"cavemarked" {
					global digwatch1
					set dy [lindex [dig_next $digwatch1 $gnome_ref1] 1]
					if {$dy<$comp_val&&$dy>10} {return true} {return false}
				}
				"cavedeleted" {
					global digwatch1
					dig_resetid $gnome_ref1
					if {[lindex [dig_next $digwatch1 $gnome_ref1] 1]<$comp_val} {return false} {return true}
				}
				"stonesfree" {
					global cavedig1 cavedig2
					if {[get_hmap $cavedig1 $cavedig2]<10} {return true}
					return false }
				"stoneset" {
					global door2
					if { [obj_query $door2 -class Grenzstein -boundingbox {1 -1 -16 9 1 1} -flagpos build -flagneg boxed -limit 1] } { return true } { return false }
				}
				"stonesetwrong" {
					global door2
					if { [obj_query $door2 -class Grenzstein -flagpos build -flagneg boxed -limit 1] } { return true } { return false }
				}
				"stonepacked" {
					if { [obj_query this -class Grenzstein -flagpos boxed -limit 1] } { return true } { return false }
				}
				"gnomenearpuppet" { if {[obj_query $walktarget "-class Zwerg -owner 0 -range 10 -limit 1"]} {return true} {return false} }
				"gnomehurt" {
					for {set i 1} {$i<5} {incr i} {
						if {[vector_dist [get_pos [subst \$gnome_ref$i]] [get_pos $walktarget]]<10} {
							if {[get_attrib [subst \$gnome_ref$i] atr_Hitpoints]<[lindex $comp_val $i]-0.02} {
								return true
							}
						}
					}
					return false
				}
				"gnomeexper" {
					for {set i 1} {$i<5} {incr i} {
//						log "$i attr: [get_attrib [subst \$gnome_ref$i] exp_Kampf]"
						if {[get_attrib [subst \$gnome_ref$i] exp_Kampf]>$try_increase} {
							return true
						}
					}
					return false
				}
				"firetoolow" {
					if {$wait_increase<50} {return false} {return true}
					if {[get_posy $door]-[get_posy $fireplace]>0.9} {return true} {return false}
				}
				"readyfortournament" {
					if {abs([get_posy $fireplace]-[get_posy $door])>1} {return false}
					for {set i 1} {$i<5} {incr i} {
						if {[vector_dist [get_pos $fireplace] [get_pos [subst \$gnome_ref$i]]]>15} {return false}
						if {[get_attrib [subst \$gnome_ref$i] atr_Hitpoints]<0.995} {return false}
						foreach atr {atr_Hitpoints atr_Nutrition atr_Alertness atr_Mood} {
							if {[get_attrib [subst \$gnome_ref$i] $atr]<0.6} {return false}
						}
					}
					return true
				}
				"nognomemoving" {
					if {$wait_increase<10} {return false}
					set i 0
					set ok true
					set nl [list]
					foreach gnome $othervar {
						if {[vector_abs [vector_sub [get_pos $gnome] [lindex $comp_val $i]]]>0.05} {
							set ok false
						}
						lappend nl [get_pos $gnome]
						incr i
					}
					set comp_val $nl
					return $ok
				}
			}
		}
		proc elf_action {args} {
			global reference prodcnt current_soundfile
			global gnomename1 gnomename2 gnomename3 gnomename4 gnomename5 begin end
			global gnomegender1 gnomegender2 gnomegender3 gnomegender4 gnomegender5
			set waittime 0
			if {[state_getenablecnt this]!=1} {state_reset this;state_enable this}
			elf finishcode this ""
			foreach param $args {
				if {[string index $param 0]=="-"&&![string is digit [string index $param 1]]} {
					set command [string range $param 1 end]
				} else {
					log "elf command $command $param"
					switch $command {
						"set" {
//							elf finishcode this {state_enable this;log "finished set"}
							elf set_pos [concat [lrange $param 0 1] 16.0]
							log "elf set_pos \{[concat [lrange $param 0 1] 16.0]\}"
						}
						"move" {
//							elf finishcode this {state_enable this;log "finished set"}
							elf move [concat [lrange $param 0 1] 16.0]
							log "elf move \{[concat [lrange $param 0 1] 16.0]\}"
							set waittime [hmax $waittime [vector_dist [elf get_pos] $param]]
						}
						"setexact" {
//							elf finishcode this {state_enable this;log "finished set"}
							elf set_pos $param
							log "elf set_pos \{$param\}"
						}
						"moveexact" {
//							elf finishcode this {state_enable this;log "finished set"}
							elf move $param
							log "elf move \{$param\}"
							set waittime [hmax $waittime [vector_dist [elf get_pos] $param]]
						}
						"screen" {
							if {$param=="none"} {
								elf stop
							} else {
								if {$param=="center"} {
									set param {400 300 16}
								}
								state_disable this
								elf finishcode this "state_enable this;elf stop"
								elf movescreen $param
								elf finishcode this "state_enable this;elf stop"
								log "elf movescreen \{$param\}"
								set waittime 0

							}
						}
						"nearscreen" {
							if {$param=="left"} {
								set xdiff -1
							} else {
								set xdiff 1
							}
							set cview [get_view]
							set cx [lindex $cview 0]
							set cy [lindex $cview 1]
							set czoom [lindex $cview 2]
							set elfx [lindex [elf get_pos] 0]
							set newx [expr {$cx+$xdiff*($czoom*5+5)}]
							if {$param=="left"&&$elfx<$newx||$param!="left"&&$elfx>$newx} {
								elf set_pos [list $newx $cy 16]
							}
							set waittime 0
						}
						"speak" {
							set seqtext [get_text $param]
							set soundmarker [get_soundmarker $param]
							if {$soundmarker!=""} {
								set start [lindex $soundmarker 0]
								set stop [lindex $soundmarker 1]
								set speechtime [expr {$stop-$start}]
								exec wigsound.exe $current_soundfile $start $stop &
								//seq_audiostream play $start $stop
							} else {
								set speechtime [expr {[string length $seqtext]*0.1}]
							}
							speechicon 0 clear
							speechicon 0 add $seqtext $speechtime
							set waittime [hmax $waittime $speechtime]
						}
						"anim" {
							elf action $param
							set waittime [hmax $waittime 3]
						}
						"wait" {
							if {[string index $param 0]=="="} {
								set waittime [string trimleft $param "="]
							} else {
								set waittime [hmax $waittime $param]
							}
						}
					}
				}
			}
			log "waittime $waittime"
			if {$waittime} {
				state_disable this
				action this wait $waittime {state_enable this}
			}
		}
		proc delete_wrong_mark {} {
			global digwatchtunnel
			set x [expr {int([lindex $digwatchtunnel 0])+7}]
			set y [hf2i [lindex $digwatchtunnel 1]]
			incr y -2
			for {set i [expr {$x-14}]} {$i<$x} {incr i} {
				for {set j [expr {$y-7}]} {$j<$y} {incr j} {
					dig_mark 0 $i $j 2
				}
			}
		}
		proc get_text {param} {
			global reference prodcnt
			global gnomename1 gnomename2 gnomename3 gnomename4 gnomename5 begin end
			global gnomegender1 gnomegender2 gnomegender3 gnomegender4 gnomegender5
			set seqfile [open data/scripts/text/sequences/Tutorial_[locale].txt r]
			gets $seqfile seqline
			while {![eof $seqfile]&&$param!=[lindex $seqline 0]} {
				gets $seqfile seqline
			}
			close $seqfile
			if {[lindex $seqline 0]!=$param} {set seqline {dummy "Text line $param not found!"}}
	//		log "seqence_line: $seqline"
			set seqtext [lrange $seqline 1 end]
			if {-1==[string first "_" $seqtext]} {
				set seqtext [subst $seqtext]
			} else {
				set seqtext [split $seqtext "_"]
				set seqtext [subst [string map [lrange $seqtext 1 end] [subst [lindex $seqtext 0]]]]
			}
			set seqtext [string map {"|" \n} [join $seqtext]]
			if {""==$seqtext} {set seqtext "[locale] version!"}
			return $seqtext
		}
		proc get_soundmarker {param} {
			set markerfile [open data/scripts/sequences/soundmarker/Tutmarker_[locale].txt r]
			gets $markerfile line
			while {![eof $markerfile]&&$param!=[lindex $line 0]} {
				gets $markerfile line
			}
			close $markerfile
			if {[lindex $line 0]!=$param} {elf text "Soundmarker $param not found!" 5}
			if {[string is double [lindex $line 1]]} {
				return [lrange $line 1 2]
			} else {
				elf text "soundmarker warning: $line"
			}
			return ""
		}
		proc soundfile_open {filename} {
			global current_soundfile
			if {![seq_audiostream open $filename.mp3]} {
				log "WARNING: soundfile $filename.mp3 not found"
			} else {
				set current_soundfile $filename
			}
		}
		proc task_to_ticker {id} {
			global nt_id
			set text [get_text $id]
			lappend nt_id [newsticker new 0 -text $text -time 7200 -category progress]
		}
		proc clear_ticker {} {
			global nt_id
			while {$nt_id!=""} {
				set entry [lindex $nt_id 0]
				newsticker delete $entry
				set nt_id [lnand $entry $nt_id]
			}
		}
		proc game_over {} {
			show_loading 1

			set MapOffset [map getoffset]
			set iXN [lindex $MapOffset 0]
			set iYN [lindex $MapOffset 1]
			set iXP [expr $iXN + 100]
			set iYP [expr $iYN + 100]

			reset_map $iXN $iYN $iXP $iYP

			set iXMid [expr ($iXN + $iXP) / 2.0]
			set iYMid [expr ($iYN + $iYP) / 2.0]
			set_pos this "$iXMid $iYMid 15"
			log "************ $iXMid $iYMid 15"
			set_fogofwar this -50 -50

			sel /obj
			set_view 32.2 32.1 1.5 -0.3 0.0		;# set inital camera view (x y zoom)
			call templates/unq_tod.tcl
			MapTemplateSet [expr 16 + $iXN] [expr 16 + $iYN]
			show_loading no
			state_disable this
		}
		proc cameracorrection {pos zoom pers {activate 1}} {
			global standardview tocheck
			set currentview [get_view]
			set needto_correct 0
			if {$pos} {
				if {abs([lindex $standardview 0]-[lindex $currentview 0])>$pos||abs([lindex $standardview 1]-[lindex $currentview 1])>$pos} {set needto_correct 1}
			}
			if {$zoom} {
				if {abs([lindex $standardview 2]-[lindex $currentview 2])>$zoom} {set needto_correct 1}
			}
			if {$pers} {
				if {abs([lindex $standardview 3]-[lindex $currentview 3])>$pers||abs([lindex $standardview 4]-[lindex $currentview 4])>$pers} {set needto_correct 1}
			}
			log "correcting view ($needto_correct) $tocheck"
			log "current: $currentview"
			log "standard: $standardview"
			if {$needto_correct} {
				if {$activate} {
					set_sequenceactive this 1
					viewlock 1
				}
				eval "set_view $standardview 1"
				state_triggerfresh this correction
			}
		}
		proc create_trigger {gnomeref script {range 5}} {
			set_sequenceactive this 0
			sel /obj
			set seq [new Sequence_triggered "" [get_pos $gnomeref] {0 0 0}]
			call_method $seq set_sequencescript $script
			trigger create $seq any_object "sequencer_activate"
			trigger set_target_class $seq Zwerg
			trigger set_target_range $seq $range
			trigger set_target_owner $seq [get_owner $gnomeref]
			trigger set_checktimer $seq 1
		}
		proc waittime {sec} {
			state_disable this
			action this wait $sec {state_enable this}
		}
		proc self_destroy {} {
			global mypos tutorial
			sel /obj
			set trigger [new Trigger_Tournament "" $mypos {0 0 0}]
			call_method $trigger set_tutorial $tutorial
			timer_event $trigger evt_timer0 -repeat 0 -userid 0 -attime [expr [gettime]+2]
			if {[obj_query this -class Feuerstelle -owner 0 -limit 1]==0} {
				set fire [new Feuerstelle "" [vector_add $mypos {-42 0 0}] {0 0 0}]
				set_physic $fire true
				set_owner $fire 0
				set_autolight $fire false
				set_boxed $fire false
			}
			del this
		}
//		timer_event this evt_timer0 -repeat 0 -userid 0 -attime [expr [gettime]+15]
//		timer_event this evt_timer1 -repeat 0 -userid 0 -attime [expr [gettime]+22]
	}
	handle_event evt_system_gamestart {
		log "[get_objname this] evt_system_gamestart : updating soundfile! $current_soundfile"
		if {$current_soundfile!=""} {soundfile_open $current_soundfile}
	}
	handle_event evt_timer0 {
		log "evt0"
		sel /obj
		set mypos [get_pos this]
		set seq [new Sequence_instant "" [vector_add $mypos {-0.13 -0.04 1.68}] {0 0 0}]
		set mymusicpos [vector_add $mypos { -20 0 0 }]
//		adaptive_sound marker tutorial $mymusicpos
//		adaptive_sound changethemenow tutorial
		call_method $seq set_sequencescript "tut_1100"
		call_method $seq set_vars "tut $tutorial"
		//option set showUI 1
	}
	handle_event evt_timer1 {
		log "evt1"
		state_enable this
	}
	handle_event selfdestroy {
		self_destroy
	}
}
def_class Sequence_triggered none dummy 0 {} {
	call scripts/classes/story/sequencer.tcl
	obj_init {
		set_selectable this 0
		set_hoverable this 0
		call scripts/classes/story/sequencer.tcl
		set_visibility this 0
	}
}
def_class Sequence_instant none dummy 0 {} {
	call scripts/classes/story/sequencer.tcl
	def_event start_sequence
	def_event feuer
	obj_init {
		set_selectable this 0
		set_hoverable this 0
		call scripts/classes/story/sequencer.tcl
		set_visibility this 0
		set weiter 0
//		sequencer_activate
		timer_event this start_sequence -repeat 0 -userid 0 -attime [expr [gettime]+0.5]
	}
	handle_event start_sequence {
		sequencer_activate
	}
	handle_event feuer {
		if {$weiter} {
			blow_particlesource $weiter 0 [vector_pack 0.1 0 0]
			timer_event this feuer -repeat 0 -userid 0 -attime [expr [gettime]+1.5]
		}
	}
}
