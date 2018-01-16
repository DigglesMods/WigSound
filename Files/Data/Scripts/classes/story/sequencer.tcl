//verhau by Ageraluon

if {[in_class_def]} {

	def_event evt_elf_talk
	def_event evt_elf_enable
	def_event evt_eye_focussing

	method set_sequencescript {script} {
		set sequencescript $script
	}

	method set_vars {vars} {
		for {set i 0} {$i<[llength $vars]} {incr i 2} {
			set [lindex $vars $i] [lindex $vars [expr $i+1]]
			lappend known_vars [lindex $vars $i]
		}
	}

	method preset_actors {alist} {
		foreach a $alist {
			add_actor $a
		}
		set actors_preset 1
	}

	method disable_autoidle {} {
		set autoidling 0
	}

	method destroy {} {
		destroy
	}

	method slog {txt} {
		slog $txt
	}

	method disable_logging {} {
		set seq_log_enabled 0
	}

	method eval_newsticker {prc} {
		set ret "error"
		catch { set ret [$prc] }
		return $ret
	}

	method seq_enable {who} {
		global followaction_list
		set followaction ""
		if { $who != "elf" } {
			set followaction [lindex $followaction_list $who]
		}
		if { [llength $followaction] != 0 } {
			//slog "$who: $followaction"
			if {$followaction=="loop"} {
				set followaction [subst \$followaction$who]
				lrep followaction_list $who [subst \$followaction$who]
			}
			set nextaction [lrem followaction 0]
			lrep followaction_list $who $followaction
			if {$nextaction=="loopstart"} {
				set followaction$who $followaction
				set nextaction [lindex $followaction 0]
				lrem followaction 0
				lrep followaction_list $who $followaction
			}
			if {[llength [lindex $nextaction 0]]>1} {set nextaction [lindex $nextaction [irandom [llength $nextaction]]]}
//			slog "--do_action $nextaction $who"
			eval "do_action $nextaction $who"
		} else {
			sequence_enable $who
		}
	}

	method seq_talk {who} {
		global talktime_list actors txt_animlist idleanim_list lastani acttexter
		set actor [lindex $actors $who]
		set time [gettime]
		set autoanim 0
		set animtype 0
		set anims [lindex $txt_animlist $who]
		set nextanim ""
		if { [llength $anims] == 0 } {
		} else {
			set nextanim [lindex $anims 0]
			switch $nextanim {
				"Auto"	{
							set nextanim ""
							set autoanim 1
							set animtype 0
						}
				"PosAc"	{
							set nextanim ""
							set autoanim 1
							set animtype 1
						}
				"PosReac"	{
							set nextanim ""
							set autoanim 1
							set animtype 2
						}
				"NegAc"	{
							set nextanim ""
							set autoanim 1
							set animtype 3
						}
				"NegReac"	{
							set nextanim ""
							set autoanim 1
							set animtype 4
						}

				"NoAnim" {
							set nextanim ""
						}
				default	{
							//set anims [lreplace $anims 0 0]
							lrem anims 0
							//set txt_animlist [lreplace $txt_animlist $who $who $anims]
							lrep txt_animlist $who $anims
						}
			}
		}
		if { $time < [lindex $talktime_list $who] || $nextanim != ""} {
			slog "time: $time end: [lindex $talktime_list $who]"
			sequence_disable $who
			if { $autoanim == 1 } {
				set anilist {talkacnta talkacntb talkacntc}
				if {$animtype == 1 } {
					set anilist {talkacpoa talkacpob talkacpoc}
				} elseif { $animtype == 2 } {
					set anilist {talkrepoa talkrepob talkrepoc}
				} elseif { $animtype == 3 } {
					set anilist {talkacnga talkacngb talkacngc}
				} elseif { $animtype == 4 } {
					set anilist {talkrenga talkrengb talkrengc}
				}

				set lastidx [lsearch $anilist $lastani]
				if { $lastidx != -1 } {
					//set anilist [lreplace $anilist $lastidx $lastidx]
					lrem anilist $lastidx
				}
				set idxmax [llength $anilist]
				set idxsel [irandom $idxmax]
				set ani [lindex $anilist $idxsel]
				set lastani $ani
			} else {
				set ani $nextanim
			}
			if { $autoanim || $ani != "" } {
				set eaction "action $actor anim $ani \{state_enable $actor ; call_method [get_ref this] seq_talk $who\}"
			} else {
				set dur [expr [lindex $talktime_list $who] - $time]

				set idleanim [lindex $idleanim_list $who]
				slog "idleanim_list : $idleanim_list"
				switch $idleanim {
					"Standard"	{	call_method $actor idle_anim	}
					"None"		{}
					default		{	set_anim $actor $idleanim 0 2	}
				}
				set eaction "action $actor wait $dur \{call_method [get_ref this] seq_enable $who\}"
			}
			slog "eact: $eaction"
			eval $eaction
		} else {
			slog "timeout... (or animout)"
			set idleanim [lindex $idleanim_list $who]
			switch $idleanim {
				"Standard"	{	call_method $actor idle_anim	}
				"None"		{}
				default		{	set_anim $actor $idleanim 0 2	}
			}
			sequence_enable $who
		}
	}

	method seq_talk_elf {} {
		global elf_time anim_list
		set nextanim ""
		set autoanim 0
		if { [llength $anim_list] == 0 } {
		} else {
			set nextanim [lindex $anim_list 0]
			switch $nextanim {
				"Auto"	{
							set nextanim ""
							set autoanim 1
						}
				"NoAnim" {
							set nextanim ""
						}
				default	{
							//set anim_list [lreplace $anim_list 0 0]
							lrem anim_list 0
						}
			}
		}
		slog "nextanim: '$nextanim'"
		slog "time: [gettime] end: $elf_time"
		if { [gettime] < $elf_time || $nextanim != ""} {
			sequence_disable elf
			if { $autoanim == 1 } {
				set anilist {reden_a reden_b}
				set idxmax [llength $anilist]
				set idxsel [irandom $idxmax]
				set ani [lindex $anilist $idxsel]
			} else {
				set ani $nextanim
			}
			if { !$autoanim && $ani == "" } {
				set ani standanim
			}
			set eaction "elf action $ani"
			set offset_time [expr [db_animlength elfe.$ani] / 10.0 + 1.0]
			log "offset_time fuer '$ani' $offset_time"
			timer_event this evt_elf_talk -userid 2 -repeat 0 -attime [expr [gettime]+$offset_time]

			slog "eact: $eaction"
			eval $eaction
		} else {
			slog "timeout... (or animout)"
			sequence_enable elf
		}
	}

	state eval_sequence {
		if { [get_sequencebreaked] } {
			slog "Sequencer sequence breaked..."
			set bTime [gettime]
			//log "--------------------- Break TimeStamp Start: $bTime"
			set is_breaked 1
			while { [parse_next 1] } {	}
			set is_breaked 0
			//log "--------------------- Break TimeStamp Stop : [expr [gettime] - $bTime]"
			shut_sequencer
			return
		}
		if {[wait_time]} {return}
		if {$wait_forelf == 1 && $enable_elf == 1} {
				//log "Warte bis elfe frei wird"
				return
			}

		if { $wait_camera } {
			if { [get_camerafollowdist] > 4.0 || [get_cameramoving] } {
					log "Sequence is waiting for camera..."
				return
			} else {
				set wait_camera 0
			}
		}
//		if {1&[string index [lindex [split [gettime] "."] 1] 0]} {slog "$enable_list waits for $wait_for ($axel_increase)"}
//		slog "$enable_list waits for $wait_for --- actors: $actors ($axel_increase) "
		if { $wait_next||!$wait_next } {	;# FIXME (No one was here yet!!! (DOCH AXEL!!!!!!!!!!!!))
			for {set i 0} {$i < [llength $actors]} {incr i} {
//				slog "\[ $i  [lindex $enable_list $i] wf: [lindex $wait_for $i]";]
				if { [lindex $wait_for $i] == 1 } {
					if { [lindex $enable_list $i]  == 1 } {
						incr axel_increase
						return
					}
				}
			}
			//log "$wait_forelf elfwaitsfor $enable_elf"
		}
		if { ![parse_next 0] } {
			slog "Sequencer sequence end..."
			shut_sequencer
		} else {
			set axel_increase 0
		}
	}

	state sleep {
		log "Sequencer Warning: Illegal state enter 'sleep' !"
		state_disable this
	}


	handle_event evt_elf_talk {
		call_method this seq_talk_elf
	}

	handle_event evt_elf_enable {
		call_method this seq_enable elf
	}

	handle_event evt_eye_focussing {
		eye_focus_update
	}

} else {
	//#set_anim this kiste.standard 0 0

	call data/scripts/misc/file_wrapper.tcl

	// Trigger dürfen nicht gelöscht werden !
	set_undeletable this 1

	set sequencescript "data/scripts/classes/sequencer/sequences/seq_test2.tcl"
	set actors [list]
	set actors_preset 0
	set enable_list [list]
	set enable_elf [list]
	set talktime_list [list]
	set color_list [list]
	set txt_animlist [list]
	set object_list [list]
	set file 0
	set activated 0
	set wait_for [list]
	set wait_forelf 0
	set wait_next 0
	set wait_camera 0
	set dontwait 0
	set viewpos [list]
	set known_vars [list]
	set axel_increase 0
	set disable_state 0
	set lastani "none"
	set followaction_list [list]
	set eyefocus_list [list]
	set connect_list [list]
	set textfile "xxx"
	set acttexter 0
	set activate_list [list]
	set talkissue_activate ""
	set talkissue_delete ""
	set feen_list [list]
	set wait_time_var 0
	set actcameraset -1
	set camsetlist [list]
	set audio_marker [list]
	set seq_log_enabled 0
	set seq_was_breaked 0
	set first_line 1
	set state_enable_list [list]
	set autoidling 1
	set is_breaked 0
	set sequence_counter 0

	set Error_Cnt_Glob 0
	set Error_Cnt_Seq 0
	set evalerrMsg "no_error"

	sm_send_message this "create"

	set_anim this trigger_fahne.standard 0 0
	if {![get_mapedit]} {
		set_visibility this 0
	}

	proc reset {} {
		global actors object_list followaction_list
		set actors [list]
		set object_list [list]
		set followaction_list [list]
	}

	proc sequencer_activate {} {
		global actors sequencescript file activated viewpos talkissue_delete object_list
		global actors_preset autoidling

		if {!$actors_preset} {reset}

		gametime factor 1.0
		textwin hide

		if {$autoidling} {park_obj_actions { Zwerg Wuker Troll Drachenbaby}}

		if {$talkissue_delete!=""} {
			set players_gnomes [obj_query this -class Zwerg -owner 0 -cloaked 1]
			if {$players_gnomes==0} {set players_gnomes {}}
			foreach gnome $players_gnomes {
				call_method $gnome talk_issue_delete $talkissue_delete
			}
		}
		timer_event this evt_eye_focussing -userid 3 -repeat -1 -interval 1 ;# -attime [expr {[gettime]+2}]
		if {$actors_preset} {
			foreach a $actors {
				remove_parked_obj $a
			}
		} else {
			set actors [list]
		}
		set object_list [list]

		#### StoryMgr Event Messages !!!
		sm_send_message this "activate"

		init_camsets

		set viewpos [get_view]
		set actuatorlist [list]
		catch { set actuatorlist [trigger get_actuators this] }
		slog "actl: $actuatorlist"
		if { [llength $actuatorlist] > 0 } {
			set actuator [lindex $actuatorlist 0]
			foreach item $actuatorlist {
				add_actor $item
			}
		} else {
			set actuator [obj_query this "-class Zwerg -owner own -range 200 -limit 1 -cloaked 1"]
			if { $actuator == 0 } {
				//return 0
			}
		}
		set activated 1
		#lappend actors $actuator
		if { [obj_valid $actuator] } {
			slog "Trigger activated through [get_objname $actuator]"
		}
		if {[set file [parse_file $sequencescript]]!=0} {
			slog "Trigger sequence script loaded... ($sequencescript) $file (this=[get_ref this])"
			init_sequencer
			state_reset this
			if { [llength $actors] == 0 } {
				add_actor $actuator
			}
			state_trigger this eval_sequence
			state_enable this
			return 1
		}
	}

	proc sq_auto_idle {{SPos "TriggerPos"} {classes "Zwerg Troll Wuker Drachenbaby"} {range 20}} {
		global state_enable_list

		log "Autoidle activated"

	    if { $classes == "none" } {
	    	return
		}

		set pos [parse_pos $SPos]

		set objlist [obj_query this -class $classes -pos $pos -range $range -cloaked 1]

   		if { $objlist != 0 } {
			foreach item $objlist {
    			if { [get_sequenceactive $item] == 0 && [check_method [get_objclass $item] seq_idle] } {
    				call_method $item seq_idle
    				lappend state_enable_list $item
    			}
    		}
    	}
	}

	proc reset_enablelist {val} {
		global actors enable_list talktime_list color_list txt_animlist idleanim_list enable_elf
		set enable_list [list]
		set txt_animlist [list]
		set idleanim_list [list]
		set enable_elf 0
		foreach item $actors {
			lappend enable_list $val
			lappend talktime_list 0
			lappend color_list {112 255 139}
			lappend txt_animlist [list]
			lappend idleanim_list "Standard"
			lappend followaction_list ""
		}
	}

	proc add_actor {actor} {
		global actors enable_list talktime_list color_list txt_animlist idleanim_list
		global followaction_list eyefocus_list talkissue_activate
		if { $actor == 0 } {
			return
		}
 		lappend actors $actor
		lappend enable_list 0
		lappend talktime_list 0

		switch [llength $actors] {
			1		{lappend color_list {50 212 0}}
			2		{lappend color_list {130 177 115}}
			3		{lappend color_list {46 139 50}}
			4		{lappend color_list {99 150 121}}
			5		{lappend color_list {99 150 121}}
			6		{lappend color_list {99 150 121}}
			default {lappend color_list {99 150 121}}
		}

		set_particlesource $actor 1 0

		if { [get_objclass $actor] == "Zwerg" } {
			set_textureanimation $actor 4 0
		}

		lappend txt_animlist [list]
		lappend idleanim_list "Standard"
		lappend followaction_list ""
		lappend eyefocus_list 0
		if {[get_owner $actor]==0&&[get_objclass $actor]=="Zwerg"} {
			if {$talkissue_activate!=""} {eval "call_method $actor talk_issue_implant $talkissue_activate"}
			call_method $actor seq_hidetool
		}
		remove_parked_obj $actor
		action $actor wait 0.0 {} {}
		state_disable $actor
		set nr [expr [llength $actors] - 1]
		return $nr
	}

	proc init_pens {} {
		global TriggerPos Elfe Offtext Odin Fenris Voodoo1 Voodoo2 Knocker1 Knocker2 Brains1 Brains2 Drache Wiggle1 Wiggle2
		set TriggerPos [get_pos this]
		set Offtext {255 255 255}
		set Odin {124 220 255}
		set Elfe {255 203 247}
		set Fenris {255 118 57}
		set Voodoo1 {255 205 73}
		set Voodoo2 {255 246 0}
		set Knocker1 {201 187 130}
		set Knocker2 {188 158 126}
		set Brains1 {163 232 255}
		set Brains2 {193 163 255}
		set Drache {207 0 0}
		set Wiggle1 {112 255 139}
		set Wiggle2 {50 212 0}
	}

	proc init_sequencer {} {
		global actors
		set_sequence 1
		set_speechout 0 {{255 255 255} ""}
		set_sequenceactive this 1
		reset_enablelist 0
		init_pens
	}

	proc shut_sequencer {} {
		global actors file viewpos sequence_counter
		set_camerafollow -1
		restore_obj_actions
		set_speechout 0 {{255 255 255} ""}
		set_sequence 0
		foreach item $actors {
			if { [obj_valid $item] } {
				free_face_anim $item
				set_sequenceactive $item 0
				state_enable $item
			}
		}
		close $file
		trigger delete this
		if { $viewpos != "" } {
			set_view [lindex $viewpos 0] [lindex $viewpos 1] [lindex $viewpos 2] [lindex $viewpos 3] [lindex $viewpos 4] [lindex $viewpos 5]
		}
		destroy
		incr sequence_counter
	}

	proc sequence_enable {{who "all"}} {
		global enable_list actors enable_elf
		if { $who == "elf" } {
			log "SEQ: ELFE wird aktiviert"
			set enable_elf 0
			return
		}
		if { $who == "all" } {
			slog resetofenablelist
			reset_enablelist 0
		} else {
			//set enable_list [lreplace $enable_list $who $who 0]
			lrep enable_list $who 0
		}
	}

	proc sequence_disable {{who "all"}} {
		global enable_list actors enable_elf
		if { $who == "elf" } {
			log "SEQ: ELFE wird deaktiviert"
			set enable_elf 1
			return
		}
		if { $who == "all" } {
			reset_enablelist 1
		} else {
			//set enable_list [lreplace $enable_list $who $who 1]
			lrep enable_list $who 1
		}
	}

	proc parse_next {seq_breaked} {
		global file break_list wait_next dontwait disable_state actors first_line color_list
		global autoidling
		set wait_next 0
		while { ! $wait_next &&! [eof $file]  } {
			gets $file command
			set command [string trim $command]
			if { [string length $command] > 1 && ![string equal -length 1 "#" $command] } {
				//set plusfound 0
				set plusfound 1		;#	Test
				if { [string equal -length 1 "-" $command] } {
					set plusfound 0
					set command [string trimleft $command "-"]
				}
				if { [string equal -length 1 "+" $command] } {
					set plusfound 1
					set command [string trimleft $command "+"]
					if {$seq_breaked} {
						set disable_state 1
					}
					//set seq_breaked 0
				} else {
					set disable_state 0
				}
				if { $seq_breaked == 0 || $plusfound == 1 } {
					//log "Sequencer eval: \"$command\""
					set dontwait 0

					if { $first_line == 1 && $autoidling } {
						if { [string range $command 0 11] != "sq_auto_idle" } {
							sq_auto_idle
						}
					}

					eval $command
				} else {
					//log "Sequencer skipped: \"$command\""
				}
				if { ! $dontwait && ! $seq_breaked } {
					set wait_next [string equal -length 3 "do_" $command]
				} else {
					set wait_next 0
				}
				set first_line 0
				set command ""
			}
		}
		//log "while done wn:$wait_next eof:[eof $file]"
		if { [eof $file] } { return 0 }
		return 1
	}

	proc Name {who} {
		global actors
		return [get_objname [lindex $actors $who]]
	}

	proc Actor {who} {
		global actors
		return [lindex $actors $who]
	}

	proc Gender {actor textm textf} {
//		return "\[seq_gender $textm $textf\]"
		global acttexter actors
		slog "genderparse!!!!!!!"
		if { [get_objgender [lindex $actors $actor]] == "male" } {
			return $textm
		} else {
			return $textf
		}
	}

	proc Expression {ex textm textf} {
		//return "\[seq_expression \{$ex\} $textm $textf\]"
		if { [expr $ex] } {
			return $textm
		} else {
			return $textf
		}
	}

	proc seq_expression {ex textm textf} {
		if { [expr $ex] } {
			return $textm
		} else {
			return $textf
		}
	}

	proc seq_gender {textm textf} {
		global acttexter actors
		slog "genderparse!!!!!!!"
		if { [get_objgender [lindex $actors $acttexter]] == "male" } {
			return $textm
		} else {
			return $textf
		}
	}

	proc Male {actor textm} {
//		return "\[seq_male $textm\]"
		global acttexter actors
		if { [get_objgender [lindex $actors $actor]] == "male" } {
			return $textm
		}
	}

	proc seq_male {textm} {
		global acttexter actors
		if { [get_objgender [lindex $actors $acttexter]] == "male" } {
			return $textm
		}
	}

	proc Female {actor textf} {
//		return "\[seq_female $textf\]"
		global acttexter actors
		if { [get_objgender [lindex $actors $actor]] == "female" } {
			return $textf
		}
	}

	proc seq_female {textf} {
		global acttexter actors
		if { [get_objgender [lindex $actors $acttexter]] == "female" } {
			return $textf
		}
	}

	proc lindex0 {lst} {
		set i [string first " " $lst]
		if { $i < 1 } {
			return $lst
		}
		incr i -1
		set ret [string range $lst 0 $i]
		return $ret
	}

	proc parse_file {callscript} {
		if {[string first ".tcl" $callscript] == -1} {
			append callscript ".tcl"
		}
		set scriptpath data/scripts/sequences/
		set scriptdirs {menue Oberwelt Urwald Schwefel Kristall Lava Trailer Test}
		foreach dir $scriptdirs {
			if {[file exists ${scriptpath}${dir}/$callscript]} {
				set callscript ${scriptpath}${dir}/$callscript
				break
			}
		}
		if { [catch { set scriptfile [open $callscript r] }] } {
			log "Sequencer.Error ([get_objname this]) : script not found \"$callscript\" "
			return 0
		} else {
			return $scriptfile
		}
	}

	proc parse_text {txt} {
		global acttexter
		if {[string is integer [string trim [string range $txt 0 2] 0]]&&[string length $txt]<7} {
			global known_vars textfile
			foreach var $known_vars {global $var}
			set current_textfile ${textfile}_[locale]
			if {![file exists data/scripts/text/sequences/$current_textfile.txt]} {
				slog "Sequencer Warning: data/scripts/text/sequences/$current_textfile.txt does not exist !"
				set textfile "default"
				set textline $txt
				set txt "1000x"
			}
			set seqfile [open data/scripts/text/sequences/$current_textfile.txt r]
			gets $seqfile seqline
			while {![eof $seqfile]&&$txt!=[lindex0 $seqline]} {
				gets $seqfile seqline
			}
			close $seqfile
			if {[lindex0 $seqline]!=$txt} {set seqline {dummy "Text line $txt not found!"}}
			slog "seqence_line: $seqline"
			set seqtext [string trim [string range $seqline [string length $txt] end]]
			if {-1==[string first "_" $seqtext]} {
				set seqtext [subst $seqtext]
			} else {
				set seqtext [split $seqtext "_"]
				set seqtext [subst [string map [lrange $seqtext 1 end] [subst [lindex $seqtext 0]]]]
			}
			set txt [string map {\n |} $seqtext]
		}
		return $txt
	}

	proc parse_pos {penposactor} {
		global actors $penposactor
		if { [llength $penposactor] == 3} {
			return $penposactor
		}
		if { [string is integer $penposactor] } {
			return [get_pos [lindex $actors $penposactor]]
		}
		if { ![catch { set pos [subst $$penposactor] }] } {
			return $pos
		}
		slog "Sequencer invalid <pos/pen/actor> : $penposactor"
	}

	proc parse_pen {pen idx} {
		if { [string is double $pen] } {
			return $pen
		}
		set pos [parse_pos $pen]
		return [lindex $pos $idx]
	}

	proc opts_formation {pen nr} {
		global $pen$nr
		return [subst $$pen$nr]
	}

	proc parse_actors {who} {
		global actors
		if { $who == "all" } {
			set who [list]
			set nr 0
			foreach item $actors {
				lappend who $nr
				incr nr
			}
		}
		if { [lindex $who end] == "..." } {
			set who [lreplace $who end end]
			for {set i [expr [lindex $who end] + 1]} {$i < [llength $actors]} {incr i} {
				lappend who $i
			}
		}
		set nrofactors [llength $actors]
		set oldwho $who
		set who [list]
		foreach item $oldwho {
			if { $item <= $nrofactors } {
				lappend who $item
			}
		}
		return $who
	}

	proc parse_objects {which} {
		global object_list
		if { $which == "all" } {
			set which [list]
			set nr 0
			foreach item $object_list {
				lappend which $nr
				incr nr
			}
		}
		if { [lindex $which end] == "..." } {
			set which [lreplace $which end end]
			for {set i [expr [lindex $which end] + 1]} {$i < [llength $object_list]} {incr i} {
				lappend which $i
			}
		}
		set nrofobjs [llength $object_list]
		set oldwhich $which
		set which [list]
		foreach item $oldwhich {
			if { $item <= $nrofobjs } {
				lappend which $item
			}
		}
		return $which
	}


//#     Sequence commands:

	proc sq_color {who col} {
		global color_list
		set col [parse_pos $col]
		set who [parse_actors $who]
		foreach item $who {
			//set color_list [lreplace $color_list $item $item $col]
			lrep color_list $item $col
		}
		slog "collist: $color_list"
	}


	proc sq_object {cmd opt1 {opt2 0} {opt3 0} {opt4 ""}} {
		global object_list
		switch $cmd {
			"summon"	{
							#set who [parse_actors $opt2]
							set cnt 0
							foreach item $opt1 {
								sel /obj
								set object [new $item]
								set_owner $object $opt3
								if { [llength $opt2] > $cnt } {
									set pos [parse_pos [lindex $opt2 $cnt]]
								}
								set_pos $object $pos
								lappend object_list $object
								incr cnt

								if { $opt4 == "add" } {
									add_actor $object
								}
							}
						}
			"delete"	{
							set which [parse_objects $opt1]
							set del_list [list]

							foreach item $which {
								lappend del_list [lindex $object_list $item]
							}
							foreach item $del_list {
								set idx [lsearch $object_list $item]
								if { $idx != -1 } {
									//set object_list [lreplace $object_list $idx $idx]
									lrem object_list $idx
									//if {[obj_valid $item]} {
										del $item
									//}
								}
							}
						}
			"kill"	{
							set which [parse_objects $opt1]
							set del_list [list]

							foreach item $which {
								lappend del_list [lindex $object_list $item]
							}
							foreach item $del_list {
								set idx [lsearch $object_list $item]
								if { $idx != -1 } {
									//set object_list [lreplace $object_list $idx $idx]
									lrem object_list $idx
									call_method $item die
								}
							}
						}
			"beam"	{
							set which [parse_objects $opt1]
							set pos [parse_pos $opt2]
							foreach item $which {
								set_pos [lindex $object_list $item] $pos
							}
						}
			"move"  {
							set which [parse_objects $opt1]
							set pos [parse_pos $opt2]
							foreach item $which {
								action [lindex $object_list $item] move "\{$pos\} $opt3"
							}
						}
			default		{ slog "Sequencer: invalid sq_object command: $cmd" }
		}
	}

	proc Object {id} {
		global object_list
		return [lindex $object_list $id]
	}

	proc Getobjpos {cla {who 0} {rng 100} {owner any}} {
		global actors
		set pos [parse_pos $who]
		set oq [obj_query this "-pos \{$pos\} -class $cla -owner $owner -range $rng -limit 1 -cloaked 1"]
		set res {0 0 0}
		if { $oq != 0 } {
			set res [get_pos $oq]
		}
		return $res
	}


	proc Getobjref {cla {who 0} {rng 100}} {
		global actors
		set pos [parse_pos $who]
		set oq [obj_query this "-pos \{$pos\} -class $cla -range $rng -limit 1 -cloaked 1"]
		return $oq
	}

	proc sq_actor {cmd type {opt1 100} {opt2 1} {opt3 "any"} {opt4 ""} {opt5 ""}} {
		global actors idleanim_list followaction_list eyefocus_list
		if {$opt4==""} {
			set opt4 [get_pos this]
		} else {
			set opt4 [parse_pos $opt4]
		}
		switch $cmd {
			"find"	{
						log "----> obj_query this -class $type -pos $opt4 -range $opt1 -owner $opt3 -flagpos $opt5 -cloaked 1"
						set actorsfound [obj_query this -class $type -pos $opt4 -range $opt1 -owner $opt3 -flagpos $opt5 -cloaked 1]
						set cnt 0
						foreach item $actorsfound {
							log "--> found: $item [get_objname $item] [get_owner $item]"
							if { [lsearch $actors $item] == -1 } {
								add_actor $item
								incr cnt
							}
							if { $cnt >= $opt2 } {
								break
							}
						}
					}
			"idleanim" {
						set who [parse_actors $type]
						foreach item $who {
							//set idleanim_list [lreplace $idleanim_list $item $item $opt1]
							lrep idleanim_list $item $opt1
						}
					}
			"actionlist" {
						set who [parse_actors $type]
						foreach item $who {
							lrep followaction_list $item $opt1
							global followaction$item
							set followaction$item $opt1
						}
			//			slog $followaction_list
					}
			"focus" {
						set who [parse_actors $type]
						if {$opt1=="none"} {set whom 0} {set whom [lindex $actors $opt1]}
						foreach item $who {
							if {[obj_valid $whom] && ($whom != "")} {
								lrep eyefocus_list $item $whom
								call_method [lindex $actors $item] set_eyefocus $whom
							}
						}
					}
			"express" {
						set who [parse_actors $type]
						foreach item $who {
							call_method [lindex $actors $item] set_special_feeling_fanim $opt1
						}
					}
			"mouth" {
						set who [parse_actors $type]
						foreach item $who {
							call_method [lindex $actors $item] start_fanim $opt1 "-mesh face"
						}
					}
			"eyes" {
						set who [parse_actors $type]
						foreach item $who {
							call_method [lindex $actors $item] start_fanim $opt1 "-mesh eyes"
						}
					}
			"setrot" {
						set who [parse_actors $type]
						set pos 0
						switch $opt1 {
							"front"	{ set ang 0 }
							"left"	{ set ang 1.57 }
							"right"	{ set ang 4.71 }
							"back"	{ set ang 3.14 }
							default { if {-1==[string first "." $opt1]} {
									set pos [parse_pos $opt1]
								} else {
									set ang $opt1
							} }
						}
						foreach item $who {
							set itemref [lindex $actors $item]
							if {$pos!=0} {
								set ang [get_anglexz [get_pos $itemref] $pos]
							}
							set_roty $itemref $ang
						}
					}
			default { slog "Sequencer: invalid sq_actor command: $cmd" }
		}
	}

	proc do_idle {who} {
		global idleanim_list actors
		set who [parse_actors $who]
		foreach item $who {
			set idleanim [lindex $idleanim_list $item]
			set actor [lindex $actors $item]
			switch $idleanim {
				"Standard"	{	call_method $actor idle_anim	}
				"None"		{}
				default		{	set_anim $actor $idleanim 0 2}
			}

		}
	}

	proc sq_text {cmd filename} {
		global textfile
		switch $cmd {
			"file"	{ set textfile $filename }
		}
	}

	proc parse_audio_file {name} {
		global audio_marker soundfile
		set current_textfile ${name}_[locale]
		if {![file exists data/scripts/sequences/soundmarker/$current_textfile.txt]} {
			slog "Sequencer Warning: data/scripts/sequences/soundmarker/$current_textfile.txt does not exist !"
			return
		}
		set seqfile [open data/scripts/sequences/soundmarker/$current_textfile.txt r]
		//gets $seqfile seqline

		set soundfile ""
		set audio_marker [list]

		set bMarker 0
		while {![eof $seqfile]} {
			gets $seqfile seqline

			if { $bMarker == 1 } {
				if { $seqline != "" } {
					set name 	[lindex $seqline 0]
					set start 	[lindex $seqline 1]
					set stop 	[lindex $seqline 2]
					set startF 	[lindex $seqline 3]
					set stopF 	[lindex $seqline 4]
					if { $startF == "" } {
						set startF 0
					}
					if { $stopF == "" } {
						set stopF 0
					}
					lappend audio_marker [list $name $start $stop $startF $stopF]
					slog "Audio Marker: [list $name $start $stop]"
				}
			}
			if { [lindex0 $seqline] == "soundfile" } {
				set soundfile [lindex $seqline 1]
			}
			if { [lindex0 $seqline] == "marker" } {
				set bMarker 1
			}
		}
		close $seqfile

		if { $soundfile != "" } {
			if { ![seq_audiostream open $soundfile] } {
				slog "Sequencer Warning: Audiofile '$soundfile' not found !"
			}
		}
	}

	proc sq_audio {cmd data} {
		//global blah
		switch $cmd {
			"open"	{
						parse_audio_file $data
					}
		}
	}

	proc sq_music {theme pos} {
		set pos [parse_pos $pos]
		if {$theme != ""} {
			if {$pos != ""} {
				adaptive_sound marker $theme $pos
				slog "Musicmarker set with theme: $theme on pos: $pos"
			} else { slog "Invalid <pos> in sq_music" }
    	} else { slog "Invalid <theme> in sq_music" }
	}


	proc sq_pen {cmd nam opt {opt2 4} {opt3 0.0}} {
		global actors $nam
		switch $cmd {
			"set"   { set $nam [parse_pos $opt] }
			"setx"	{ set $nam [lreplace [subst $$nam] 0 0 [parse_pen $opt 0]] }
			"sety"	{ set $nam [lreplace [subst $$nam] 1 1 [parse_pen $opt 1]] }
			"setz"	{ set $nam [lreplace [subst $$nam] 2 2 [parse_pen $opt 2]] }
			"move"  {
						if { [catch { set $nam [vector_add [subst $$nam] [parse_pos $opt]] }] } {
							slog "Sequencer invalid <name> in function sq_pen move: $nam"
						}
					}
			"form"	{
						set pos [subst $$nam]
						if { [string first "Row" $opt] != -1 } {			;#------------------Row----------------------------
							if { [string first "Ver" $opt] != -1 } {
								set vect {0 0 1.3}
							} else {		;# Hor = default
								set vect {1.3 0 0}
							}

							if { [string first "Up" $opt] != -1 || [string first "Le" $opt] != -1 } {
								set vect [vector_mul $vect -1]
								set startvec [vector_add $pos $vect]
							} elseif { [string first "Ri" $opt] != -1 || [string first "Do" $opt] != -1 } {
								set startvec [vector_add $pos $vect]
							} else {		;# Mi = default
								set startvec [vector_sub $pos [vector_mul $vect [expr $opt2 / 2]]]
							}

							for {set i 0} {$i < $opt2} {incr i} {
								global $nam$i
								set $nam$i $startvec
								set startvec [vector_add $startvec $vect]
							}
						} elseif { [string first "Cir" $opt] != -1 } {		;#-------------------Circle---------------------
							set rad [hceil [expr (($opt2 / 3.14) - 1)]]
							set rad [hmax 1.0 $rad]
							set al [expr 6.2831 / $opt2]
							set actal [expr ($opt3 * 6.2831) / 360]

							for {set i 0} {$i < $opt2} {incr i} {
								global $nam$i
								set vec [list [expr cos($actal)] 0 [expr sin($actal) * 2]]
								set vec [vector_mul $vec $rad]
								set vec [vector_add $vec $pos]
								set $nam$i $vec
								fincr actal $al
							}
						}
					}
			default { slog "Sequencer: invalid sq_pen command: $cmd" }
		}
	}

	proc init_camsets {} {
		global actors viewpos actcameraset camsetlist
		lappend camsetlist {standard 	{1.0 	{{s 0.5 0.3} {s 1.0 0.0}}}}
		lappend camsetlist {inout 		{0 		{{s 0.3 0.7} {s 1.0 0.0}}}}

	}

	proc add_camset {name ispeed cset} {
		global actors viewpos actcameraset camsetlist
		lappend camsetlist "$name \{$ispeed \{$cset\}\}"
		//slog "*** $camsetlist"
	}

	proc sel_camset {name} {
		global actors viewpos actcameraset camsetlist
		set sset [lsearch -glob $camsetlist "$name *"]
		if { $sset != -1 } {
			set actcameraset [lindex [lindex $camsetlist $sset] 1]
		} else {
			slog "Sequencer Warning: cameraset: $name not found !!!"
			set  actcameraset -1
		}

	}

	proc sq_screenvibe {att {sus -1} {dec -1} {amx -1} {frx -1} {amy -1} {fry -1}} {
		global is_breaked

		if { $is_breaked } {
			return
		}

		set valid [expr ($sus | $dec | $amx | $frx | $amy | $fry) != -1]
		if { $valid } {
			screenvibe $att $sus $dec $amx $frx $amy $fry
		} else {
			switch $att {
				"steps" 	{screenvibe 0   0.1 	0.2 	0   	0   	0.1 	100}
				"equake7"   {screenvibe 2   3   	2   	0.1 	103 	0.1 	200}
				"equake4"   {screenvibe 1   2   	1   	0.1 	103 	0.1 	200}
				"ring"      {screenvibe 0   2 		0   	0.1 	96  	0   	0}
				"kawumm"    {screenvibe 0	0.15 	0.1 	0.16 	100 	0.21 	114}
				default 	{log "Sequencer Warning: invalid sq_screenvibe preset '$att' or not enough arguments (should be 7)"}
			}
		}
	}

	proc sq_camera {cmd {who 0} {zoom 1.0} {dx 0} {dy 0} {speed 1} {opt "none"}} {
		global actors viewpos actcameraset camsetlist

		set freeze 0
		switch $cmd {
			"follow"	{ 	set_camerafollow [lindex $actors $who] $zoom
							return 		}
			"fix"		{	set move 0	}
			"move"		{	set move 1	}
			"get"		{	set viewpos [get_view 1] ; return }
			"getold"	{	set viewpos [get_view] ; return	}
			"clear"		{	set viewpos "" ; return	}
			"stop"		{	set_camerafollow -1	; return}
			"selset"	{	sel_camset $who ; return	}
			"addset"	{	add_camset $who $zoom $dx ; return }
			default		{ slog "Sequencer invalid sq_camera command: $cmd";return }

		}
		set_camerafollow -1
		set vpos [parse_pos $who]
		set x [lindex $vpos 0]
		set y [expr [lindex $vpos 1] - 0.75]
		set z [lindex $vpos 2]

		if { [string first $opt "Freeze"] != -1 } {
			set freeze 1
		}

		set camset 0
		if { $actcameraset != -1 } {
			camera_set [lindex $actcameraset 0] [lindex $actcameraset 1]
			set camset 1
			//slog "** camera_set [lindex $actcameraset 0] [lindex $actcameraset 1] ($actcameraset)"
		}

		if { [string first $opt "SelfRot"] != -1 || [string first $speed "SelfRot"] != -1} {
			slog "set_view $x $y $zoom $dx $dy $move $freeze $speed $camset"
			set_view $x $y $zoom $dx $dy $move $freeze $speed $camset
		} else {
			slog "set_viewpos $x $y $z $zoom $dx $dy $move $freeze $speed $camset"
			set_viewpos $x $y $z $zoom $dx $dy $move $freeze $speed $camset
		}
	}

	proc sq_wait {who} {
		global wait_for actors enable_list wait_forelf
		set wait_for [list]
		set wait_forelf 0
		set eidx [lsearch $who "elf"]
		if { $eidx != -1 } {
			set wait_forelf 1
			//set who [lreplace $who $eidx $eidx]
			lrem who $eidx
		}

		foreach item $actors {
			lappend wait_for 0
		}
		switch $who {
			"all" 	{
						set wait_for [list]
						foreach item $actors {
							lappend wait_for 1
						}
					}
			"none"	{ }
			default {
						set who [parse_actors $who]
						foreach item $who {
							//set wait_for [lreplace $wait_for $item $item 1]
							lrep wait_for $item 1
						}
					}
		}
		slog "sqwait: $who -> ($wait_for)"
	}

	proc sq_activate {typ args} {
		global activate_list
		switch $typ {
			"Zwerg"		{set tclass "PseudoZwerg"}
			"Zwerge"	{set tclass "Zwerg"}
			"Troll"		{set tclass "Troll"}
			"Zuschauer"	{set tclass "Zuschauer"}
			default		{slog "Sequencer invalid sq_activate type: $typ";return}
		}
		set range 500
		set limit 100
		set argc [llength $args]
		set actarg 0
		while { $actarg < $argc - 1 } {
			set opt1 [lindex $args $actarg]
			set opt2 [lindex $args [expr $actarg + 1]]
			switch $opt1 {
				"range"		{set range $opt2}
				"limit"		{set limit $opt2}
				default		{slog "Sequencer invalid sq_activate option: $opt1";return}
			}
			incr actarg 2
		}
		set plist [lnand 0 [obj_query this "-class $tclass -limit $limit -range $range -cloaked 1"]]
		if {$tclass == "PseudoZwerg"} {
			foreach item $plist {
				call_method $item activate
			}
        } else {
			foreach item $plist {
				set_sequenceactive $item 1
				lappend  activate_list $item
			}
		}
	}

	proc wait_time {} {
		global wait_time_var

		if {$wait_time_var > 0} {
			set time [hmin 0.5 [expr $wait_time_var - [gettime]]]
			if {$time <= 0} {
				set wait_time_var 0
				return 0
			}
			state_disable this
			action this wait $time {state_enable this}
			return 1
		}
		return 0
	}

	proc do_wait {{cmd "none"} {opt 0.0}} {
		global wait_camera wait_time_var is_breaked
		if { $is_breaked } { return }
		switch $cmd {
			"time"		{  set wait_time_var [expr [gettime] + $opt]}
			"camera"	{	set wait_camera 1	}
			"none"		{}
			default		{slog "Sequencer invalid do_wait command: $cmd";return}
		}
	}

	proc odo_text {txt who {opt "Auto"} {txttime "Auto"} {textlock "Auto"} {offtext "NoOff"} {t_color "Auto"}} {
		global actors talktime_list color_list txt_animlist acttexter soundfile
		set TextSpeed [option get TextSpeed]
		set TextSpeed [hmax 3 $TextSpeed]

		set txt [parse_text $txt]

		set text_list [split $txt "|"]
		set anim_list [split $opt "|"]
		set who [parse_actors $who]
		while {[llength $anim_list] < [llength $who] } {
			lappend anim_list [lindex $anim_list end]
		}

		set ldiff [expr [llength $who] - [llength $text_list]]
		if { $ldiff > 0 } {
			for {set i 0} {$i < $ldiff} {incr i} {
				lappend text_list [lindex $text_list end]
			}
		}

		set time_list [list]
		set col_list [list]
		set maxtime 0
		set nextcolor {155 155 155}
		set idx 0
		set lastidx 0

		set i 0
		set text ""
		set time 0
		set acta 0
		set newactor 0

		foreach item $text_list {
			if { $i < 4 && [llength $who] > $i } {
				set newactor [lindex $actors [lindex $who $i]]
			}
			if {  $newactor != $acta && $acta != 0 } {
				speechicon $acta add $text [hmax $time 2.0]
				set text ""
				set time 0
			}
			if { $text == "" } {
				set text [lindex $text_list $i]
			} else {
				set text "$text\n[lindex $text_list $i]"
			}
			fincr time [expr [string length $item] * (1 / double($TextSpeed))]
			set acta $newactor
			incr i
		}
		speechicon [lindex $actors [lindex $who end]] add $text [hmax $time 2.0]
		set idx 0
		set lastidx 0

		foreach item $text_list {
			set time [hmax [expr [string length $item] * (1 / double($TextSpeed))] 1.0]
			if { $txttime != "Auto" } {
				set time $txttime
			}
			lappend time_list $time

			set maxtime [hmax $time $maxtime]

			if { $idx < 4 && [llength $who] > $idx } {
				set name [get_objname [lindex $actors [lindex $who $idx]]]
				set oldtext [lindex $text_list $idx]
				set acttexter $idx
				set oldtext [subst $oldtext]
				//set text_list [lreplace $text_list $idx $idx "$name : $oldtext"]
				lrep text_list $idx "$name : $oldtext"
				set nextcolor [lindex $color_list [lindex $who $idx]]
				set lastidx $idx

			} else {
				set oldtext [lindex $text_list $idx]
				set acttexter $idx
				set oldtext [subst $oldtext]
				//set text_list [lreplace $text_list $idx $idx $oldtext]
				lrep text_list $idx $oldtext

				if { $oldtext != "" } {
					set oldtime [lindex $time_list $lastidx]
					fincr oldtime $time
					fincr maxtime $time
				}
				//set time_list [lreplace $time_list $lastidx $lastidx $oldtime]
				lrep time_list $lastidx $oldtime

			}

			lappend col_list $nextcolor
			incr idx
		}
		set resstr ""
		for {set i 0} {$i < 4} {incr i} {
			lappend resstr [lindex $col_list $i] [lindex $text_list $i]
		}
		slog "res: $maxtime $resstr"
		set_speechout $maxtime $resstr


		set idx 0
		foreach item $who {
//			set txt_animlist [lreplace $txt_animlist $item $item [lindex $anim_list $idx]]
			lrep txt_animlist $item [lindex $anim_list $idx]
			set endtime [expr [gettime] + [lindex $time_list $idx]]
//			set talktime_list [lreplace $talktime_list $item $item $endtime]
			lrep talktime_list $item $endtime
			sequence_disable $item
			call_method this seq_talk $item
			incr idx
		}
	}

	proc get_audio_marker {name {female 0}} {
		global audio_marker
		foreach item $audio_marker {
			if { [lindex $item 0] == $name } {
				set ms [lindex $item 1]
				set me [lindex $item 2]
				set fs [lindex $item 3]
				set fe [lindex $item 4]
				set ret "$ms $me"
				if { $female } {
					if { [expr $fs + $fe] > 0 } {
						slog "fem found!!!!!"
						set ret "$fs $fe"
					}
				} else {
					if { ![expr [expr $ms + $me] > 0] } {
						slog "mal not found!!!!!"
						set ret "$fs $fe"
					}
				}
				return $ret
			}
		}
		slog "Sequencer Warning: Audiomarker '$name' not found !"
		return ""
	}

	proc do_script {cmd opt1 {chance 1.0} {counter -1}} {
		global file sequence_counter
		switch $cmd {
			"change" {
				if {$counter!=-1&&$sequence_counter<$counter||rand()>$chance} {return}
				set newfile [parse_file $opt1]
				if {$newfile==0} {return}
				close $file
				set file $newfile
			}
			"skip" {
				if {$counter!=-1&&$sequence_counter<$counter} {
					shut_sequencer
				}
			}
		}
	}

	proc sq_sound {marker {obj 0}} {
		global actors is_breaked soundfile

		if { $is_breaked } { return }

		set female 0
		if { $obj != 0 } {
			set female [get_alternateanimdb [lindex $actors $obj]]
		}
		set am [get_audio_marker $marker $female]
		if  { $am != "" } {
			set start 	[lindex $am 0]
			set stop 	[lindex $am 1]
			set time 	[expr $stop - $start]
		} else {
			log "Sequencer Warning: Audiomarker '$marker' not found !"
			return
		}
		exec wigsound.exe $soundfile $start $stop &
		//seq_audiostream play $start $stop
	}

	proc do_text {txt who {opt "Auto"} {txttime "Auto"} {textlock "Auto"} {offtext "NoOff"} {t_color "Auto"}} {
		global actors talktime_list color_list txt_animlist acttexter is_breaked soundfile

		if { $is_breaked } {return}

		set txt [parse_text $txt]
		set txt [string map {| \n} $txt]

		set text_list [split $txt "|"]
		set anim_list $opt
		set who [lindex [parse_actors $who] 0]


		set time_list [list]
		set autotime 0
		set time 0

		set female [get_alternateanimdb [lindex $actors $who]]
		slog "female !!!!!!: $female"
		if { $txttime != "Auto" } {
			set am [get_audio_marker $txttime $female]
			if  { $am != "" } {
				set start 	[lindex $am 0]
				set stop 	[lindex $am 1]
				set time 	[expr $stop - $start]
			} else {
				set autotime 1
			}
		} else {
			set autotime 1
		}

		if { $autotime == 1 } {
			set time [hmax 1.6 [calc_text_time $txt]]
		} else {
			exec wigsound.exe $soundfile $start $stop &
			//seq_audiostream play $start $stop
		}

		slog "time: $time txt: $txt who: $who opt: $opt txttime: $txttime textlock: $textlock offtext: $offtext txt $txt"

		if {$t_color !="Auto"} {
			set color $t_color
		} else {
			set color {255 255 255}
			if { $who < [llength $color_list] } {
				set color [lindex $color_list $who]
			}
		}

		set bForce 0
		if { $offtext == "Force" } { set bForce 1 }

		if { $offtext != "NoOff" } {
//			set text_list [split $txt "|"]
			set resstr ""
			for {set i 0} {$i < 4} {incr i} {
				lappend resstr $color [lindex $text_list $i]
			}

            sequence_disable $who
			set_speechout $time $resstr $bForce
			action [lindex $actors $who] wait $time "call_method [get_ref this] seq_enable $who"

		} else {
			speechicon [lindex $actors $who] add $txt $time 1 0
			if { $textlock != "Auto" } {
				speechicon [lindex $actors $who] lock [lindex $textlock 0] [lindex $textlock 1]
			}

			set resstr ""
			for {set i 0} {$i < 4} {incr i} {
				lappend resstr $color [lindex $text_list $i]
			}
			set_speechout $time $resstr $bForce
			log "set_speechout $time $resstr"

		//        slog "## [get_ref this]"

			lrep txt_animlist $who $anim_list
			set endtime [expr [gettime] + $time]
			lrep talktime_list $who $endtime
			sequence_disable $who
			call_method this seq_talk $who
		}
	}


	proc elf_text {txt {opt "Auto"} {txttime "Auto"} {textlock "Auto"}} {
		global elf_time anim_list soundfile

//		Jan war hier *g*
//	ICH AUCH - muhahaha!!
        set autotime 0

		set txt [parse_text $txt]
		set txt [string map {| \n} $txt]
		slog "textwas: $txt"
		set text_list [split $txt "|"]

		set anim_list [split $opt "|"]
		slog "anim_list: $anim_list"

		if { $txttime != "Auto" } {
			set am [get_audio_marker $txttime 0]
			if  { $am != "" } {
				set start 	[lindex $am 0]
				set stop 	[lindex $am 1]
				set time 	[expr $stop - $start]
			} else {
				set autotime 1
			}
		} else {
			set autotime 1
		}

		if { $autotime == 1 } {
			set time [hmax 1.6 [calc_text_time $txt]]
		} else {
			exec wigsound.exe $soundfile $start $stop &
			//seq_audiostream play $start $stop
		}

		set elf_time [expr [gettime] + $time]

		//speechicon 0 add $txt $time 1
		//if { $textlock != "Auto" } {
		//	speechicon 0 lock [lindex $textlock 0] [lindex $textlock 1]
		//}

		set color {255 203 247}
		set resstr ""
		for {set i 0} {$i < 4} {incr i} {
			lappend resstr $color [lindex $text_list $i]
		}
		set_speechout $time $resstr

		//elf say $txt

		call_method this seq_talk_elf
	}

	proc do_action {type opts who} {
		global actors disable_state is_breaked
		set aopts $opts
		set eactors [list]
		set recalcangle 0
		set animset 0
		set dontstop 0
		//set alternwanim ""
		if { $type == "run" } {
			set type "walk"
			set animset 1
		} elseif { $type == "panicflee" } {
			set type "walk"
			set animset 9
			set dontstop 1
		} elseif { $type == "flee" } {
			set type "walk"
			set animset 9
		} elseif { $type == "transport" } {
			set type "walk"
			set animset 7
		} elseif { $type == "sneak" } {
			set type "walk"
			set animset 8
		} elseif { $type == "walktired" } {
			set type "walk"
			set animset 2
		} elseif { $type == "zombie" } {
			set type "walk"
			set animset 10
		} elseif { $type == "skipp" } {
			set type "walk"
			set animset 12
		} elseif { $type == "drunk" } {
			set type "walk"
			set animset 13
		} elseif { $type == "walkfit" } {
			set type "walk"
			set animset 14
		} elseif { $type == "barrelwalk" } {
			set type "walk"
			set animset 15
		} elseif { $type == "strike" } {
			set type "walk"
			set animset 16
		}


		set who [parse_actors $who]
		foreach item $who {
			lappend eactors "[lindex $actors $item] $item"
		}

		switch $type {
			"rotate"	{
							switch $opts {
								"front"	{ set aopts 0 }
								"left"	{ set aopts 1.57 }
								"right"	{ set aopts 4.71 }
								"back"	{ set aopts 3.14 }
								default { if {-1==[string first "." $opts]} {set recalcangle 1} }
							}
						}
			"walk"		{	set aopts "\"-target \{[parse_pos $opts]\} -animsets $animset -dontstop $dontstop\"" }
			"beam"		{	set aopts [parse_pos $opts]	}
			default		{}
		}

		set acount 0
		set nrofacts [llength $eactors]

		foreach item $eactors {

			if { $nrofacts > 1 } {
				switch $type {
					"walk"		{	set aopts "\"-target \{[opts_formation $opts $acount]\} -animsets $animset -dontstop $dontstop\""	}
					"beam"		{	set aopts [opts_formation $opts $acount]	}
					default {}
				}
			}

			incr acount

			set actor [lindex $item 0]
			set nr 	  [lindex $item 1]

			if { $recalcangle } {
				slog "ang- posthis:[get_pos $actor] posother:[parse_pos $opts] angle:[get_anglexz [get_pos $actor] [parse_pos $opts]]"
				set aopts [get_anglexz [get_pos $actor] [parse_pos $opts]]
			}

			if { $type == "beam" } {
				action $actor wait 0
				set_pos $actor $aopts
				sequence_enable $nr
			} elseif { $type == "setrot" } {
				action $actor wait 0
				set_roty $actor $aopts
				sequence_enable $nr
			} elseif {!$is_breaked} {
				if { $disable_state } {
					state_disable $actor
					set eaction "action $actor $type $aopts \{state_enable [get_ref this]\}"
				} else {
					set logstr "$type [string trim $aopts "\""]"

					sequence_disable $nr
					//set eaction "action $actor $type $aopts \{catch \{call_method [get_ref this] seq_enable $nr\};call_method [get_ref this] slog (\[expr \[gettime\]-[gettime]\],finish'[get_objname $actor]+$logstr+')\} \{call_method [get_ref this] slog (\[expr \[gettime\]-[gettime]\],break'[get_objname $actor]+$logstr+')\}"
					set eaction "action $actor $type $aopts \{catch \{call_method [get_ref this] seq_enable $nr\}\} \{\}"
				}
				slog "eaction: $eaction"
				eval $eaction
				if { $type == "anim" } {
					if {[set fanim [get_classaniminfo [get_objclass $actor] $aopts]]!=""} {
						if {$fanim=="Illegel Anim"} {slog "illegal Anim: $aopts!!!";return true}
						set submesh [lindex $fanim 0]
						set fanim [lrange $fanim 1 end]
						call_method $actor start_fanim $fanim "-mesh $submesh"
					}
				}
			}
		}
		set disable_state 0
	}

	proc do_elf {cmd {opt1 "nothing"} {opt2 "Auto"} {opt3 0.6} {opt4 "Auto"}} {
		global actors is_breaked

		if { $is_breaked } {
			if { $cmd == "hide" }	{	elf hide	}
			if { $cmd == "lookat" && $opt1 == "none" } { elf lookat }
			return
		}

		switch $cmd {
			"move"		{
							log "in move: this = [get_ref this]"
							sequence_disable elf
							elf finishcode this "call_method [get_ref this] seq_enable elf"
							set pos [parse_pos $opt1]
							//log "in move: opt1 = $opt1, pos = $pos]"
							set pos [vector_add $pos {0 -1.2 -0.5}]
							set eaction "elf move {$pos}"
							log "in move: eaction = $eaction"
							eval $eaction
						}
			"movescreen" {
							sequence_disable elf
							elf finishcode this "call_method [get_ref this] seq_enable elf"
							set pos [parse_pos $opt1]
							//set pos [vector_add $pos {0 -1.2 -0.5}]
							lrep pos 2 [expr [lindex $pos 2] * -1.0]
							set eaction "elf movescreen {$pos}"
							slog "movescreen:$eaction"
							eval $eaction
						}
			"path"		{
							sequence_disable elf
							elf finishcode this "call_method [get_ref this] seq_enable elf"
							#elf finishcode this "till"
							set pos1 [parse_pos $opt1]
							set pos2 [parse_pos $opt2]
							set pos1 [vector_add $pos1 {0 -1.2 -0.5}]
							set pos2 [vector_add $pos2 {0 -1.2 -0.5}]
							set eaction "elf path {$pos1} {$pos2} $opt3"
							log "Elf - PATH: eaction = $eaction"
							eval $eaction
						}
			"crash"		{
							sequence_disable elf
							elf finishcode this "call_method [get_ref this] seq_enable elf"
							set pos [parse_pos $opt1]
							set pos [vector_add $pos {0 -1.2 0}]
							set eaction "elf crash {$pos}"
							slog "crash:$eaction"
							eval $eaction
						}
			"beam"		{
							set pos [parse_pos $opt1]
							set pos [vector_add $pos {0 -1.2 -0.5}]
							elf set_pos $pos
						}
			"anim"		{
							sequence_disable elf
							set offset_time [expr [db_animlength elfe.$opt1] / 10.0]
							log "offset_time bei $opt1 = $offset_time"
							timer_event this evt_elf_enable -userid 2 -repeat 0 -attime [expr [gettime] + $offset_time]
							elf action $opt1
						}
			"sleep"		{	elf sleep	}
			"standard"	{	elf standard	}
			"hide"		{	elf hide	}
			"idle"		{	elf idle	}
			"text"		{
							if { $opt3 == 0.6 } {
								set opt3 "Auto"
							}
							elf_text $opt1 $opt2 $opt3 $opt4
						}
			"lookat"	{
							if { ![string is integer $opt1] } {
								elf lookat
							} else {
								set act [lindex $actors $opt1]
								elf lookat $act
							}
						}
			default		{slog "Sequencer invalid do_elf command: $cmd";return}
		}
		slog "cmd was: $cmd"
	}

	proc do_toolputaway {who} {
		global actors is_breaked

		set eactors [list]
		set who [parse_actors $who]
		foreach item $who {
			lappend eactors "[lindex $actors $item] $item"
		}
		foreach item $eactors {
			set actor [lindex $item 0]
			set nr 	  [lindex $item 1]
			set thisref [get_ref this]
			if { [string first [get_objclass $actor] "ZwergUsw."] == -1 } {
				continue
			}
    		if {$is_breaked} {
    			call_method $actor seq_hidetool
    			continue
    		}
			if { [call_method $actor seq_checktool] != 0 } {
				sequence_disable $nr
				action $actor anim toolputaway_a "call_method $actor seq_hidetool;action $actor anim toolputaway_b \" call_method [get_ref this] seq_enable $nr \"" "call_method $actor seq_hidetool;call_method [get_ref this] seq_enable $nr"
			}
		}
	}

	proc do_tooltakeout {tool who} {
		global actors is_breaked

		set eactors [list]
		set who [parse_actors $who]
		foreach item $who {
			lappend eactors "[lindex $actors $item] $item"
		}
		foreach item $eactors {
			log "*** showtool : $item"

			set actor [lindex $item 0]
			set nr 	  [lindex $item 1]
			set thisref [get_ref this]
			if { [string first [get_objclass $actor] "ZwergUsw."] == -1 } {
				continue
			}
    		if {$is_breaked} {
    			call_method $actor seq_showtool $tool
    			continue
    		}

			sequence_disable $nr
			action $actor anim tooltakeout_a "call_method $actor seq_showtool $tool;action $actor anim tooltakeout_b \" call_method [get_ref this] seq_enable $nr \"" "call_method $actor seq_showtool $tool;call_method [get_ref this] seq_enable $nr"
		}
	}

	proc connect {cl} {
		global connect_list
		foreach item $cl {
			lappend connect_list $item
		}
	}

	proc delete_connected {} {
		global connect_list
		foreach item $connect_list {
			set ol [obj_query this "-class $item -cloaked 1"]
			if { $ol != 0 } {
				foreach cl $ol {

					#### StoryMgr Event Messages !!!
					sm_send_message $cl "shut"

					set_undeletable $cl 0
					del $cl
				}
			} else {
				slog "[get_objname this]: Sequencer warning connect class not found: '$item' !"
			}
		}
	}

	proc fee_text {txt {txttime "Auto"}} {
		global soundfile
		
		set autotime 0;#Masc

		set TextSpeed [option get TextSpeed]
		set TextSpeed [hmax 3 $TextSpeed]

		set txt [parse_text $txt]
		set txt [string map {| \n} $txt]

		set fee_time [hmax [expr [string length $txt] * (1 / double($TextSpeed))] 1.0]
		set fee_time [expr $fee_time + [gettime]]



		if { $txttime != "Auto" } {
			set am [get_audio_marker $txttime 0]
			if  { $am != "" } {
				set start 	[lindex $am 0]
				set stop 	[lindex $am 1]
				set time 	[expr $stop - $start]
			} else {
				set autotime 1
			}
		} else {
			set autotime 1
		}

		if { $autotime == 1 } {
			set time [hmax 1.6 [calc_text_time $txt]]
		} else {
			exec wigsound.exe $soundfile $start $stop &
			//seq_audiostream play $start $stop
		}

		set fee_time $time

		set color {255 255 0}
		set text_list [split $txt "|"]
		for {set i 0} {$i < 4} {incr i} {
			lappend resstr $color [lindex $text_list $i]
		}
		set_speechout $fee_time $resstr

	}

	proc do_fee {cmd {opt1 "nothing"} {opt2 "Auto"} {opt3 0.6}} {
		global feen_list
		if { $feen_list == [list] } {
			if { $cmd == "shut" } { return }
			set feen_list [lnand 0 [obj_query this "-class Fee -range 50 -cloaked 1"]]
		}

		switch $cmd {
		"text"	{ fee_text $opt1 $opt2}
		"move"	{
					foreach item $feen_list {
						set pos [parse_pos $opt1]
						call_method $item move_to $pos
					}
				}
		"dither"	{ foreach item $feen_list { call_method $item dither $opt1 } }
		"radius"	{ foreach item $feen_list { call_method $item radius $opt1 } }
		"normal"	{ foreach item $feen_list { call_method $item normal } }
		"back"  {
					foreach item $feen_list {
						call_method $item move_back
					}
				}
		 default	{ slog "Sequencer invalid do_fee command: $cmd"; return }

		}
	}

	proc do_particle {cmd {ptype "none"} {pen "none"} {dir "none"} {num "none"} {ptime 5}} {
		global is_breaked
		if { $is_breaked } { return }
		switch $cmd {
			"create" {
						if {$ptype == "none"} {
							slog "missing param \"type\" by do_particle create"
						}
						if {$pen == "none"} {
							slog "missing param \"pen\" by do_particle create"
						}
						if {$dir == "none"} {
							slog "missing param \"dir\" by do_particle create"
						}
						if {$num == "none"} {
							slog "missing param \"num\" by do_particle create"
						}
						create_particlesource $ptype [parse_pos $pen] $dir $num $ptime
			}

			default  { slog "Sequencer invalid do_particle command: $cmd"; return }
		}
	}

	proc eye_focus_update {} {
		global eyefocus_list actors
		if {![llength $eyefocus_list]} {return}
		set len [llength $actors]
		for {set i 0} {$i<$len} {incr i} {
			set ef [lindex $eyefocus_list $i]
			if {$ef} {
				set who [lindex $actors $i]
				if {[obj_valid $who]} {
					if {[get_objclass $who]=="Zwerg"} {
						call_method $who update_eyefocus
					}
				}
			}
		}
	}

	proc free_face_anim {ac} {
		if {[check_method [get_objclass $ac] reset_fanim_feeling]} {
			call_method $ac set_eyefocus 0
			call_method $ac reset_fanim_feeling
		}
	}

	proc deactivate_activated {} {
		global activate_list state_enable_list
		if {[llength $activate_list] == 0} {return}
		for {set i 0} {$i < [llength $activate_list]} {incr i} {
			catch { set_sequenceactive [lindex $activate_list $i] 0 }
		}
		set activate_list [list]

		foreach item $state_enable_list {
			//tasklist_clear $item
			//action $item wait 0 {state_enable $item} {state_enable $item}
		}
		set state_enable_list [list]
	}

	proc destroy_permanently {} {
		destroy 1
	}

	proc destroy {{delete 0}} {
		global actors
		#### StoryMgr Event Messages !!!
		deactivate_activated
		do_fee shut
		//sprechblasen leeren
		foreach item $actors {
			if {![obj_valid $item]} {continue}
			speechicon $item clear
		}
		if { ! $delete && [check_method [get_objclass this] destroy_overload] } {
			state_trigger this sleep
			state_disable this
			call_method this destroy_overload
		} else {
			delete_connected
			sm_send_message this "shut"
			set_undeletable this 0
			del this
		}
	}

	proc slog {txt} {
		global seq_log_enabled
		if { $seq_log_enabled } {
			log $txt
		}
	}

	proc do_change {opt1 {opt2 "nothing"} {opt3 "nothing"} {opt4 "auf"} {opt5 "anim"}} {
	//do_change muetze category actor <auf|ab|both> <anim|noanim>
		global actors
		//log "----------------------do_change------------------"
		switch $opt1 {
			"muetze" {
						if {$opt4 == "auf"} {
							seq_muetze_auf $opt3 $opt2 $opt5
						} else {
							//opt4 = "ab"
							seq_muetze_ab $opt3 $opt5
						}
				//set eactors [parse_actors $opt3]
				//opt2 -> category der Muetze
				//foreach item $eactors {
				//	set ac [lindex $actors $item]
					//log "Zwerg: [get_objname $ac] setzt die Muetze $opt2"
				}
			//}
			default		{log "Sequencer invalid do_elf command: $cmd";return}
		}
	}

	proc seq_muetze_ab {who animopt} {
		slog "MUETZE_AB"
		global actors is_breaked
		set eactors [list]
		set who [parse_actors $who]
		foreach item $who {
			lappend eactors "[lindex $actors $item] $item"
		}
		foreach item $eactors {
			set actor [lindex $item 0]
			set nr 	  [lindex $item 1]
			set thisref [get_ref this]
			if { [string first [get_objclass $actor] "ZwergUsw."] == -1 } {
				continue
			}
			if {$animopt == "noanim" || $is_breaked} {
				sequence_disable $nr
				call_method $actor del_current_muetze
				sequence_enable $nr
			} else {
				sequence_disable $nr
				action $actor anim hatofhead "action $actor anim hatofhand \"action $actor anim hatofgone \\\"call_method $actor del_current_muetze;call_method [get_ref this] seq_enable $nr\\\" \\\{\\\}\" \{\}" "call_method $actor del_current_muetze;call_method [get_ref this] seq_enable $nr"
			}
		}
	}

	proc seq_muetze_auf {who category animopt} {
		slog "MUETZE_AUF"
		global actors is_breaked
		set eactors [list]
		set who [parse_actors $who]
		foreach item $who {
			lappend eactors "[lindex $actors $item] $item"
		}
		foreach item $eactors {
			set actor [lindex $item 0]
			set nr 	  [lindex $item 1]
			set thisref [get_ref this]
			if { [string first [get_objclass $actor] "ZwergUsw."] == -1 } {
				continue
			}
			set muetze [call_method $actor get_nameofmuetze_seq $category]
			if {$animopt == "noanim" || $is_breaked} {
				sequence_disable $nr
				call_method $actor create_muetze $muetze
				sequence_enable $nr
			} else {
				sequence_disable $nr
				action $actor anim hatongone "action $actor anim hatonhand \"action $actor anim hatonhead \\\"call_method $actor create_muetze $muetze;call_method [get_ref this] seq_enable $nr\\\" \\\{\\\}\" \{\}" "call_method $actor create_muetze $muetze;call_method [get_ref this] seq_enable $nr"
			}
		}
	}

	proc DracheAutoDestroy {} {
		set bDA 0
		catch { if { [sm_get_event Drache_angegriffen] } { set bDA 1} }
		if { $bDA } {
			destroy_permanently
			return 1
		}
		return 0
	}

}
