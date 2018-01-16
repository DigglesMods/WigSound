def_class Trigger_Tournament none dummy 0 {} {
	call scripts/misc/info_obj.tcl
	def_event evt_timer0
	def_event evt_timer1
	def_event evt_system_gamestart
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
			log "activated option: $possibility"
			switch $possibility {
				"truereturn" {
					set i 1
					foreach gnome [obj_query this "-class Zwerg -owner 0 -range 200 -limit 4 -cloaked 1"] {
						set gnome_ref$i $gnome
						set gnomename$i [get_objname $gnome]
						set gnomegender$i [get_objgender $gnome]
						incr i
					}
					if {[set brewery [obj_query this -class Brauerei -owner 0 -limit 1]]} {
						call_method $brewery change_owner -1
					}
					set i 0
					foreach item [obj_query this "-class \{Dummy_Obw_standarte_a Dummy_Obw_standarte_b Dummy_Obw_standarte_c Dummy_Obw_standarte_d Dummy_Obw_standarte_e\} -range 100 -limit 5"] {
						set standarte$i $item
						incr i
					}
					foreach gatter [obj_query this "-class Zauntor_a -range 30"] {
						call_method $gatter oeffnen -1
					}
					set tocheck "truereturn."
					set_owner_attrib 0 digenable0 1
					set_owner_attrib 0 digenable1 1
					prodslot_override disable 0
					prodslot_override disable 1
					prodslot_override disable 2
					prodslot_override disable 3
					prodslot_override disable 4
					prodslot_override disable 5
					prodslot_override disable 31
				}
				"truereturn." {
					//if {!$tutorial} {tasklist_add this "elf_action -anim auffordern -speak 1010x"}
					set tocheck ".truereturn."
				}
				".truereturn." {
					set judgelist [list]
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
					set seq [new Sequence_triggered "" [get_pos $standarte1] {0 0 0}]
					call_method $seq set_sequencescript tourn_2100
					trigger create $seq callback "sequencer_activate"
					trigger set_callback $seq {expr 1}
					trigger set_checktimer $seq 1
					set gnomelist [list]
					set judgelist [lsort -index 1 -decreasing $judgelist]
					foreach entry $judgelist {
						lappend gnomelist [lindex $entry 0]
					}
					if {[get_objgender [lindex $gnomelist 0]]==[get_objgender [lindex $gnomelist 1]]} {
						set sec [lindex $gnomelist 1]
						lrem gnomelist 1
						lappend gnomelist $sec
					}
					log "preseting actors: $seq $gnomelist"
					call_method $seq preset_actors $gnomelist
					set tocheck "gnomedied braintimer tunneldigged1 tunneldigged2"
					tasklist_add this "waittime 2"
					tasklist_add this "task_to_ticker 2101a"
					tasklist_add this "park_gnomes"
					set comp_val [vector_add [get_pos $standarte1] {0 3.5 0}]
					set othervar [vector_add [get_pos $standarte0] {0 1.5 0}]
					sel /obj
					set IFA [new Info_Fog_Aufdecker]
					set_pos $IFA [vector_add [get_pos $standarte0] {1 22 4}]
					call_method $IFA Editor_Set_Info {{vorschau 2} {xrange 2} {yrange 18} {sicht 0} {owner 0}}
				}
				"braintimer" {
					create_trigger $standarte2 3 "tourn_2120"
					set tocheck "gnomedied tunneldigged1 tunneldigged2"
					tasklist_add this "waittime 2"
					tasklist_add this "close_brains_eyes"
				}
				"tunneldigged1" {
					clear_ticker
					create_trigger $standarte1 0 "tourn_2110"
					set tocheck "gnomedied tunneldigged1. objectreached"
				}
				"tunneldigged1." {
					task_to_ticker 2101b
					elf move [vector_add [get_pos $standarte0] {-1 -1 5}]
					set comp_val [obj_query $standarte1 "-class Feuerstelle -limit 1 -range 50"]
					set tocheck "gnomedied objectreached"
				}
				"tunneldigged2" {
					set comp_val [obj_query $standarte1 "-class Feuerstelle -limit 1 -range 50"]
					set tocheck "gnomedied objectreached"
				}
				"objectreached" {
					clear_ticker
					call_method $comp_val change_owner 0
					foreach g [obj_query this -class Zwerg -owner {1 2 3} -cloaked 1] {
						if {$g} {del $g}
					}
					set brewery [obj_query this -class Brauerei -owner world -limit 1]
					set switcher [obj_query $brewery "-class Schalter_hebel_holz_up -range 15 -limit 1"]
					call_method $switcher set_switchmode "hold 0"
					set voodoobrew [obj_query $standarte4 "-class Brauerei -owner 1 -limit 1 -range 1000"]
					set knockerbrew [obj_query $standarte4 "-class Brauerei -owner 2 -limit 1 -range 1000"]
					create_trigger [obj_query $comp_val -class Zwerg -owner 0 -range 100 -limit 1 -cloaked 1] 0 "tourn_2125" 100
					set fr [obj_query $brewery "-class FogRemover -limit 1 -range 30"]
					if {$fr} {call_method $fr fog_remove 0 30 4}
					call_method $brewery change_owner 0
					tasklist_add this "task_to_ticker 2101c"
					set tocheck "gnomedied itemstransported takenpannier takewheelbarrow"
				}
				"takewheelbarrow" {
					soundfile_open Clip2125
					tasklist_add this "elf_action -screen \{200 200 16\}"
					tasklist_add this "elf_action -wait 1"
					tasklist_add this "elf_action -anim warnen -speak 2125c"
					tasklist_add this "elf_action -anim verzweifeln -speak 2125d"
					set tocheck "gnomedied itemstransported"
				}
				"takenpannier" {
					set tocheck "gnomedied itemstransported"
				}
				"itemstransported" {
					clear_ticker
					prodslot_override normal 0
					tasklist_add this "elf_action -screen \{-200 300 16\}"
					tasklist_add this "elf_action -wait 1"
					tasklist_add this "elf_action -anim verzweifeln -speak 2130a"
					tasklist_add this "elf_action -anim auffordern -speak 2130b"
					tasklist_add this "task_to_ticker 2101d"
					set tocheck "gnomedied brewing"
				}
				"brewing" {
					create_trigger [obj_query $brewery -class Zwerg -owner 0 -range 100 -limit 1 -cloaked 1] 0 "tourn_2135" 100
					set tocheck "gnomedied brewedenough"
				}
				"brewedenough" {
					clear_ticker
					set door1 [obj_query $switcher "-class Tuer_kaserne -range 15 -limit 1"]
					call_method $switcher set_switchmode "hold 2"
					call_method $switcher set_actiononpress "call_method $door1 oeffnen $switcher 0.5"
					create_trigger $brewery 0 "tourn_2138" 15
					set tocheck "gnomedied objectreached."
					tasklist_add this "task_to_ticker 2101e"
					set comp_val [obj_query $brewery "-class Dummy_Obw_goldhamster -limit 1"]
				}
				"objectreached." {
					clear_ticker
					create_trigger $comp_val 0 "tourn_2140" 15
					foreach item [obj_query $comp_val "-class Schalter_hebel_holz_up -range 15 -limit 2"] {
						call_method $item set_var 2 5
					}
					set walktarget [vector_add [get_pos $comp_val] {6.5 0 4}]
					set comp_val [obj_query $comp_val -class Leiter_Kristall -pos $walktarget -range 5 -limit 1]
					set walktarget [vector_add [get_pos $comp_val] {0 -6 0}]
					set comp_val [obj_query $comp_val -class Zwerg -owner 0 -range 50 -limit 1 -cloaked 1]
					tasklist_add this "task_to_ticker 2101f"
					set tocheck "gnomedied onladdertop"
				}
				"onladdertop" {
					clear_ticker
					set fr [obj_query $comp_val -class FogRemover -range 30 -limit 1]
					if {$fr} {
						call_method $fr fog_remove 0 5 40
					}
					set_diplomacy 0 2 enemy
					tasklist_add this "task_to_ticker 2101g"
					create_trigger $comp_val 0 "tourn_2150" 15
					set tocheck "gnomedied gnomeneartodeath"
				}
				"gnomeneartodeath" {
					clear_ticker
					set comp_val [obj_query this -class Dummy_Obw_tribuene]
					set comp_val [obj_query $comp_val -class Zwerg -owner 0 -range 32 -limit 1 -cloaked 1]
					create_trigger $comp_val 0 "tourn_2160" 20
					set_sequenceactive this 0
					set tocheck "noseqexist"
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
				"noseqexist" {
					//start_fade 1 0
					prodslot_override reset
					tasklist_add this "waittime 5"
					tasklist_add this {exec_deferred {call gamesave/single_CampaignX.tcl}}
					state_disable this
				}
			}
			state_triggerfresh this task
		} else {
			incr wait_increase
			state_disable this
			action this wait 1 {state_enable this}
		}
	}
	method set_tutorial {bool} {set tutorial $bool}
	obj_init {
		set_selectable this 0
		set_hoverable this 0
		call scripts/misc/info_obj.tcl
		set player_task_progress 0
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
		set tutorial 0
		set nt_id ""
		set current_soundfile ""
		state_triggerfresh this checking
		state_disable this
		proc check_callback {player_task_progress} {
			global comp_val try_increase wait_increase othervar
			global gnome_ref1 gnome_ref2 gnome_ref3 gnome_ref4 brewery walktarget
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
				"allinspare" {
					for {set i 1} {$i<5} {incr i} {
						if {[subst \$gnome_ref$i]} {
							if {[get_remaining_sparetime [subst \$gnome_ref$i]]==0} {return false}
						}
					}
					return true
				}
				"allgnomesfine" {
					if {-1==[lsearch $comp_val "1"]} {return true}
					for {set i 1} {$i<[llength $comp_val]} {incr i} {
						if {[lindex $comp_val $i]} {
							set erg 1
							foreach atr {atr_Hitpoints atr_Nutrition atr_Alertness atr_Mood} {
								if {[get_attrib [subst \$gnome_ref$i] $atr]<0.8} {set erg 0;break}
							}
							if {$erg} {set comp_val [lreplace $comp_val $i $i 0]}
						}
					}
					return false
				}
				"gnomeneartodeath" {
					foreach gnome [obj_query [obj_query this -class Dummy_Obw_tribuene] -class Zwerg -owner {0 2} -range 30 -limit 2 -cloaked 1] {
						if {[get_attrib $gnome atr_Hitpoints]<0.66} {return true}
					}
					return false
				}
				"tunneldigged1" { if {[get_hmap [lindex $comp_val 0] [lindex $comp_val 1]]<12} {return true} {return false} }
				"tunneldigged2" { if {[get_hmap [lindex $othervar 0] [lindex $othervar 1]]<12} {return true} {return false} }
				"braintimer" { if {$wait_increase>50} {return true} {return false} }
				"objectreached" { if {[obj_query $comp_val "-class Zwerg -owner 0 -range 10 -limit 1 -cloaked 1"]} {return true} {return false} }
				"takewheelbarrow" { if {[llength [obj_query $brewery "-class \{Pilzstamm Pilzhut\} -flagpos contained"]]>2&&[obj_query $brewery "-class Holzkiepe -limit 1 -range 50 -flagneg contained"]} {
					return true } { return false } }
				"takenpannier" { if {[llength [obj_query $brewery "-class \{Pilzstamm Pilzhut\} -flagpos contained"]]>2&&![obj_query $brewery "-class Holzkiepe -limit 1 -range 50 -flagneg contained"]} {
					return true } { return false } }
				"itemstransported" { if {[llength [obj_query $brewery -class Pilzstamm -boundingbox {-15 -1 -10 10 1 10} -flagneg contained]]>3&&[llength [obj_query $brewery -class Pilzhut -boundingbox {-15 -1 -10 10 1 10} -flagneg contained]]>7} {
					return true } { return false } }
				"brewing" { if {[get_prod_slot_cnt $brewery Bier]} {
								set glist [lnand 0 [obj_query $brewery "-class Zwerg -owner 0 -range 30 -cloaked 1"]]
								foreach gnome $glist {
									if {[ref_get $gnome current_worktask]=="work"} {return true}
								}
							}
							return false }
				"brewedenough" { if {[llength [obj_query $brewery "-class Bier -range 15 -flagneg contained"]]>1} { return true } { return false } }
				"onladdertop" { if {[vector_dist [get_pos $comp_val] $walktarget]<2} {return true} {return false} }
				"noseqexist" { if {[obj_query this -class Sequence_triggered -limit 1]} {return false} {return true} }
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
		proc get_text {param} {
			global reference prodcnt
			global gnomename1 gnomename2 gnomename3 gnomename4 gnomename5 begin end
			global gnomegender1 gnomegender2 gnomegender3 gnomegender4 gnomegender5
			set seqfile [open data/scripts/text/sequences/Tournament_[locale].txt r]
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
			set markerfile [open data/scripts/sequences/soundmarker/Tourmarker_[locale].txt r]
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
		proc waittime {sec} {
			state_disable this
			action this wait $sec {state_enable this}
		}
		proc close_brains_eyes {} {
			set brains [lnand 0 [obj_query this -class Zwerg -owner 3]]
			foreach b $brains {
				set_textureanimation $b 4 9
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
		proc park_gnomes {} {
			global standarte1
			set glist [obj_query $standarte1 -class Zwerg -owner 0 -range 200]
			set glist [lrange $glist 2 3]
			set spos [vector_add [get_pos $standarte1] {-18.42 0 -9}]
			set brille 0
			foreach g $glist {
				set_worktime $g 0.0 0.0
				set_activegameplay $g 0
				set_pos $g $spos
				set_roty $g 1.3
				if {!$brille&&rand()<0.05} {
					set brille 1
					set fanim 11
				} else {
					set fanim 9
				}
				set_textureanimation $g 4 $fanim 0 2
				set_anim $g mann.schlafen_boden_loop 0 2
				sel /obj
				set gp [new Grillpilz]
				if {[inv_check $g $gp]} {
					inv_add $g $gp
				} else {
					del $gp
				}
				change_particlesource $g 1 4 {0 0 0} {0 0 0} 2 1 0 10
				set_particlesource $g 1 1
				set cmr [ref_get $g current_muetze_ref]
				if {$cmr&&[obj_valid $cmr]} {link_obj $cmr;del $cmr}
				if {[get_objgender $g]=="male"} {
					set cmr [new Dummy_Muetze_a]
				} else {
					set cmr [new Dummy_Muetze_b]
				}
				link_obj $cmr $g 4
				set spos [vector_add $spos {0.3 0 1}]
			}
		}
		proc create_trigger {gnomeref owner script {range 5}} {
			set_sequenceactive this 0
			sel /obj
			set seq [new Sequence_triggered "" [get_pos $gnomeref] {0 0 0}]
			call_method $seq set_sequencescript $script
			call_method $seq disable_autoidle
			trigger create $seq any_object "sequencer_activate"
			trigger set_target_class $seq Zwerg
			trigger set_target_range $seq $range
			trigger set_target_owner $seq $owner
			trigger set_target_count $seq 1
			trigger set_checktimer $seq 1
		}
//		timer_event this evt_timer0 -repeat 0 -userid 0 -attime [expr [gettime]+15]
//		timer_event this evt_timer1 -repeat 0 -userid 0 -attime [expr [gettime]+22]
	}

	handle_event evt_timer0 {
		log "evtt0 Tutorial==$tutorial"
		set st [expr {int([gethours])%12}]
		foreach gr [lnand 0 [obj_query this -class Zwerg -cloaked 1]] {
			set_worktime $gr $st 9.0
			call_method $gr disable_reprod
		}
		foreach pz [lnand 0 [obj_query this -class PseudoZwerg]] {
			if {$tutorial&&[get_owner $pz]==0} {
				log "Deleting PZwerg $pz"
				del $pz
			} else {
				set gr [call_method $pz activate]
				set_worktime $gr $st 9.0
				call_method $gr disable_reprod
			}
		}
		state_enable this
	}
}

def_class Trigger_Tourn_digend none dummy 0 {} {
	call scripts/misc/info_obj.tcl
	def_event evt_timer0
	obj_init {
		set_selectable this 0
		set_hoverable this 0
		timer_event this evt_timer0 -repeat 0 -userid 0 -attime [expr [gettime]+1]
		call scripts/misc/info_obj.tcl

		proc del_everything {} {
			global own
			set glist [obj_query this -class Zwerg -owner own -range 13 -cloaked 1]
			foreach g [lnand 0 $glist] {
				state_disable $g
				action $g walk "-target \{[vector_add [get_pos this] {0 -3 0}]\}" {
					del this
				}
			}
			set x [hf2i [get_posx this]]
			set y [hf2i [get_posy this]]
			incr x 3
			incr y 2
			for {set i [expr {$x-7}]} {$i<$x} {incr i} {
				for {set j [expr {$y-15}]} {$j<$y} {incr j} {
					dig_mark $own $i $j 2
				}
			}
		}
	}

	handle_event evt_timer0 {

		set own [get_owner this]
		trigger create this any_object "del_everything"
		trigger set_target_range this 2
		trigger set_target_class this "Zwerg"
		trigger set_target_owner this $own
		trigger set_checktimer this 5

	}
}

def_class Trigger_Auftrag_Odin none dummy 0 {} {
	call scripts/classes/story/sequencer.tcl
	def_event evt_timer0

	method destroy_overload {} {
		global context
		sel /obj
		set sq [new Trigger_tourn_2170 "" {157 88.5 10} {0 0 0}]
		call_method $sq set_context $context
		set fr [new FogRemover "" {152 84 10} {0 0 0}]
		call_method $fr fog_remove 0 -70 -70
		set king [obj_query this -class Zwerg -limit 1 -cloaked 1]
		if {$king} {del $king}
		set elfe [obj_query this -class Riesenelfe -limit 1]
		if {$elfe} {del $elfe}
		destroy 1
	}
	method set_context {str} {
		set context $str
	}

	obj_init {
		set_selectable this 0
		set_hoverable this 0
		timer_event this evt_timer0 -repeat 0 -userid 0 -attime [expr [gettime]+1]
		call scripts/classes/story/sequencer.tcl


		set context "tournament"

    	proc fow_wech {pos} {
    		global FR
  			sel /obj
			set FR [new FogRemover]

			set_pos $FR [vector_add $pos {0 0 0}]
			call_method $FR fog_remove 0 50 50
			call_method $FR timer_delete 30
    	}

	}

	handle_event evt_timer0 {
		set sequencescript "odin_001"
		trigger create this any_object "sequencer_activate"
		trigger set_target_range this 3.0
		trigger set_target_class this Koenig_im_Bett
		trigger set_target_owner this 0
		trigger set_target_count this 1
	}
}

def_class Trigger_tourn_2170 none dummy 0 {} {
	call scripts/classes/story/sequencer.tcl
	def_event evt_timer0
	method destroy_overload {} {
		global context
		//foreach obj [obj_query this ""] {del $obj}
		switch $context {
			"tutorial" {
				exec_deferred {call data/gamesave/single_Tutorial.tcl}
			}
			"tournament" {
				exec_deferred {call data/gamesave/single_Tournament.tcl}
			}
		}
		destroy 1
	}
	method set_context {str} {
		set context $str
	}

	obj_init {
		set_selectable this 0
		set_hoverable this 0
		timer_event this evt_timer0 -repeat 0 -userid 0 -attime [expr [gettime]+0.1]
		call scripts/classes/story/sequencer.tcl

		set context "tournament"
	}

	handle_event evt_system_gamestart {
		log "[get_objname this] evt_system_gamestart : updating soundfile!"
		if {$current_soundfile!=""} {soundfile_open $current_soundfile}
	}
	handle_event evt_timer0 {
		set sequencescript "tourn_2170"
		sequencer_activate
	}
}

