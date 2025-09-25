--Xiao Qin 5/5/2025

--function > math > comparison > logical
--in math: as > ^ > * / > + -
--not > and > or
--precedence

include "toolboxcr_fn.mxs"

--A
rollout mID "Material ID and Camera"
(
button btn1 "mtl id" across:4
checkbox cb1 "sv" offset:[4,4]
button btn2 "cam info" offset:[10,0]
checkbox cb2 "sv" offset:[21,4]

on btn1 pressed do
(
	--clear globals
	matIDArray = #()
	matIDArrayDup = #()
	matFlag = false
	
	--set locals
	local matSS = StringStream ""
	UpdateSceneMaterialLib() --important, Forces an update to the Scene Material Library (the sceneMaterials global)
	--https://help.autodesk.com/view/MAXDEV/2022/ENU/?guid=GUID-D10CEFAB-E451-4A63-968E-01AEDEFCE928
	
	for i in sceneMaterials do
	(
		if (classOf i == CoronaPhysicalMtl or classOf i == CoronaLegacyMtl or classOf i == Standardmaterial) and (i.effectsChannel != 0) then
		(
			checkMatID i
		)
		
		if classOf i == Multimaterial then
		(
			--the Multimaterial itself has material id
			if i.effectsChannel != 0 then
			(
				checkMatID i
			)
			
			--loop through its children
			for j in i do
			(
				if (j != undefined) and (j.effectsChannel != 0) then
				(
					checkMatID j
				)
			)
		)
		
		if classOf i == VRayBlendMtl then
		(
			--the VRayBlendMtl itself has material id
			if i.effectsChannel != 0 then
			(
				checkMatID i
			)
			
			for n = 1 to getNumSubMtls i do
			(
				k = getSubMtl i n
				if (k != undefined) and (k.effectsChannel != 0) then
				(
					checkMatID k
				)
			)
		)
		
		if classOf i == VRay2SidedMtl then
		(
			--the VRay2SidedMtl itself has material id
			if i.effectsChannel != 0 then
			(
				checkMatID i
			)
			
			for n = 1 to getNumSubMtls i do
			(
				k = getSubMtl i n
				if (k != undefined) and (k.effectsChannel != 0) then
				(
					checkMatID k
				)
			)
		)
	)
	
	if matIDArray.count >0 then
	(
		if matFlag == true then
		(
			format "Warning: there are duplicated material IDs!\n\n" to: matSS
		)
		
		for m in matIDArray do
		(
			if m != undefined then --possible undefined slots in matIDArray becasue IDs are not consecutive
			(
				format "ID: % | % (%)\n" m.effectsChannel m.name (classOf m) \
				to: matSS
			)
			else
			(
				format "ID: -\n" to: matSS
			)
		)
		
		if matIDArrayDup.count >0 then
		(
			format "\nDuplicated:\n\n" to: matSS
			
			for n in matIDArrayDup where n != undefined do --matIDArrayDup should have consecutive slots but just to make sure; double proof
			(
				format "ID: % | % (%)\n" n.effectsChannel n.name (classOf n) \
				to: matSS
			)
		)
		
		--done with matSS setup
		
		if cb1.checked == false then
		(
			messageBox (matSS as string) title:"Material ID"
		)
		else
		(
			exportToTxt (matSS as string) txtName:"material_id" txtDate:true
		) --cb1.checked
		
		--clear globals
		matIDArray = #()
		matIDArrayDup = #()
		
	) --matIDArray empty
	else
	(
		messageBox "No material ID set up in the scene"
	)
)

on btn2 pressed do
(
	cameraInfoSS = StringStream ""
	
	for i in cameras do
	(
		if (classOf i == CoronaCam) and (isProperty i "rotation") then
		(
			format "%\n  lens: %mm\n  exp: f/%, 1/%s, %iso\n  tm: %  vshift: % hshift: %\n  clip: %, %in\n  lock: % %\n  rot: x%, y%, z%\n\n" \
				i.name (int(i.focalLength)) (int(i.fStop)) (int(i.shutterSpeed)) (int(i.iso)) \
				i.colorMappingOverride \
				i.verticalShift i.horizontalTilt i.enableClipping (int(i.clippingNear)) (getTransformLockFlags i) (getInheritanceFlags i) \
				(quatToEuler2 i.rotation.controller.value).x (quatToEuler2 i.rotation.controller.value).y (quatToEuler2 i.rotation.controller.value).z \
				to: cameraInfoSS
		)
	)
	
	if cameraInfoSS as string == "" then
	(
		messageBox "No camera in the scene"
	)
	else
	(
		if cb2.checked == false then
		(
			messageBox (cameraInfoSS as string) title:"Camera Info"
		)
		else
		(
			exportToTxt (cameraInfoSS as string) txtName:"camera_info" txtDate:true
		) --cb2.checked
	) --cameraInfoSS as string != ""
)

) --A

--B
rollout layerFix "Layer and Render Element"
(
button btn3 "max 17 18 layer fix" align:#left
button btn4 "channel fix:" across:3 align:#left
spinner ch1 "ch" range:[1,15,7] type:#integer fieldWidth:20 offset:[15,4]
spinner ch2 "mtl" range:[1,10,3] type:#integer fieldWidth:20 offset:[12,4]
button btn5 "clear max render output file" align:#left
button btn6 "add default render settings" align:#left

on btn3 pressed do
(
	if misClickPrevention() then
	(
		if selection.count > 0 then
		(
			layerF = LayerManager.newLayer()
			for i in (selection as array) do layerF.addnode i
		)
		else
		(
			MessageBox "Nothing selected. Nothing was done."
		)
	
	)
	else --misClick
	(
		MessageBox "Nothing was done"
	)
)

on btn4 pressed do
(
	if misClickPrevention() then
	(
		renderSceneDialog.close()
		re = maxOps.GetCurRenderElementMgr()
		
		--remove all MultiMatteElement
		--notice the "0" start
		local toDelete = for i = 0 to re.NumRenderElements() where (classOf (re.GetRenderElement i) == CMasking_Mask) collect (re.GetRenderElement i)
		
		for j in toDelete do re.RemoveRenderElement j
		
		--start setup
		for k = 1 to ch1.value do
		(
			kVal = k as string
			if k <10 then
			(
				kVal = "0"+kVal
			)
			re.AddRenderElement (CMasking_Mask elementName:("Ch" + kVal + "a") mode:1 \
				objectROn:true objectGOn:true objectBOn:true objectR:(k*3-2) objectG:(k*3-1) objectB:(k*3))
		)
		
		for m = 1 to ch2.value do
		(
			mVal = m as string
			if m <10 then
			(
				mVal = "0"+mVal
			)
			re.AddRenderElement (CMasking_Mask elementName:("M" + mVal + "a") mode:1 \
				objectROn:true objectGOn:true objectBOn:true materialR:(m*3-2) materialG:(m*3-1) materialB:(m*3))
		)
		
		renderSceneDialog.open()
	)
	else --misClick
	(
		MessageBox "Nothing was done"
	)
)

on btn5 pressed do
(
	if (misClickPrevention str:"This will clear render output file, proceed?") then
	(
		renderSceneDialog.close()
		rendSaveFile = false
		rendOutputFilename = ""
		renderSceneDialog.open()
	)
	else --misClick
	(
		MessageBox "Nothing was done"
	)
)

on btn6 pressed do
(
	if (misClickPrevention str:"This will delete all current render elements, proceed?") then
	(		
		--element
		elementList = #(CESSENTIAL_Direct, CESSENTIAL_Emission, CESSENTIAL_Indirect, CESSENTIAL_Reflect,
		CESSENTIAL_Refract, CGeometry_ZDepth, CMasking_ID, CMasking_WireColor, CShading_Shadows, CTexmap)
		
		renderSceneDialog.close()
		
		--renderers.current = Corona:Corona()
		re = maxOps.GetCurRenderElementMgr()
		re.removeAllRenderElements()
		
		for i in elementList do
		(
			if i == CTexmap then
			(
				ao = CoronaAO name:"AO" maxDistance:12 colorOccluded:(color 0 0 0) colorUnoccluded:(color 255 255 255)
				re.AddRenderElement (i elementName:(i as string + "_AO") texmap:ao)
			)
			else if i == CGeometry_ZDepth then
			(
				re.AddRenderElement (i elementName:(i as string) maxZ:20000)
			)
			else if i == CMasking_ID then
			(
				re.AddRenderElement (i elementName:(i as string + "_M") what:3)
				re.AddRenderElement (i elementName:(i as string + "_G") what:2)
			)
			else
			(
				re.AddRenderElement (i elementName:(i as string))
			)
		)
		
		--setting
		CrSetting()
		
		renderSceneDialog.open()
	)
	else --misClick
	(
		MessageBox "Nothing was done"
	)
)

) --B

--C
rollout objDummy "Object to Dummy"
(
button btn7 "replace obj with point" across:2 align:#left
spinner spSize "pt" range:[1,500,50] type:#integer fieldWidth:20 offset:[5,3]

on btn7 pressed do
(
	if misClickPrevention() then
	(
		if selection.count>0 then
		(
			interested_Objects = #()
			
			--a = LayerManager.newLayer()
			--a.setname "0 to hide"
			local layerO = LayerManager.newLayerFromName "0 to hide"
	
			for i in selection do
			(
				--Do not select an object that is part of a group
				if not isGroupMember i then
				(
					append interested_Objects i
				)
				
				layerO.addnode i
			)
			
			for j in interested_Objects do
			(
				point name:("Point_"+j.name) pos:j.pos size:spSize.value
				
				--Hiding a node is easy just call
				--hide nodeToHide
				--However when i used it on groups, it
				--doesn't work so i had to select group head and
				--then call hide on current selection
				if isGroupHead j then
				(
					select j
					hide $
				)
				else
					hide j
			)

			MessageBox "Done"
		)
		else --0 selected
		(
			MessageBox "Nothing selected. Nothing was done."
		)
	)
	else --misClick
	(
		MessageBox "Nothing was done"
	)
)

) --C

--D
rollout reSetting "Render Setting"
(
button btn8 "low" width:50 across:3 align:#left
button btn9 "med" width:50 align:#center
button btn10 "high" width:50 align:#right
	
on btn8 pressed do
(
	if misClickPrevention() then
	(
		VRaySetting a:1500 b1:1 b2:2 c:1.0 d:1 e1:50 e2:20 f:300 g:"low"
	)
)

on btn9 pressed do
(
	if misClickPrevention() then
	(
		VRaySetting a:2000 b1:1 b2:4 c:1.0 d:2 e1:50 e2:20 f:1000 g:"medium"
	)
)

on btn10 pressed do
(
	if misClickPrevention() then
	(
		VRaySetting a:2500 b1:2 b2:6 c:2.0 d:3 e1:60 e2:30 f:2000 g:"high"
	)
)

) --D

--E
rollout astTrack "Asset Tracking" width:200 height:100
(
button btn11 "check" width:50 across:2 align:#left
button btn12 "close" width:50 align:#right

on btn11 pressed do
(
	ATSOps.Visible = true
	ATSOps.CheckNetworkPaths = true
	ATSOps.Refresh()
)

on btn12 pressed do
(
	ATSOps.Visible = false
	ATSOps.CheckNetworkPaths = false
	ATSOps.Refresh()
)

) --E

--F
rollout mapMissing "Map and Material"
(
button btn13 "map browser" across:2 align:#left
button btn14 "fix vray mtl" align:#right
button btn18 "non corona" across:2 align:#left
button btn22 "bitmap gamma" align:#right
button btn23 "set up mtl" align:#left
--button btn23 "fix gamma" align:#right enabled:false
--button btn24 "set output" align:#right enabled:false

--btn13 map browser
on btn13 pressed do
(

	undo off

	--0 clear globals
	try(DestroyDialog mapBrowser) catch()
	resetGlobals()
	
	--1 scenmaterials
	getMatRecursiveScene()
	
	--2 solo mats
	local maCnt = matArray.count
	for i = 1 to maCnt do
	(
		getMapRecursive matArray[i]
		countUpdate "solo mat: " i
	)
	
	/*
	--1 material
	for i in scenematerials do getMatRecursive i

	--2 set up 3 map arrays
	for i in matArray do getMapRecursive i
	*/
	
	--3 set up 3 unique map arrays
	mapBitmapArrUni = makeUniqueArray mapBitmapArr
	mapBitmapMissArrUni = makeUniqueArray mapBitmapMissArr
	mapTexmapMissArrUni = makeUniqueArray mapTexmapMissArr

	mapBitmapArrUni_str = getArrayString mapBitmapArrUni
	mapBitmapMissArrUni_str = getArrayString mapBitmapMissArrUni
	mapTexmapMissArrUni_str = getArrayString mapTexmapMissArrUni
	
	mapBitmapArrUni_cnt = getUniqueArrayCount mapBitmapArrUni mapBitmapArr
	mapBitmapMissArrUni_cnt = getUniqueArrayCount mapBitmapMissArrUni mapBitmapMissArr
	mapTexmapMissArrUni_cnt = getUniqueArrayCount mapTexmapMissArrUni mapTexmapMissArr

	--4 open rollout
	rollout mapBrowser "Map Browser"  width:550 height:540
	(
		button mapIcon width:40 height:40 across:3 align:#left
		radiobuttons bitOrMiss "type" labels:#("bitmap","bitmiss","texmiss") columns:3 align:#center offset:[-120, 5]
		radiobuttons mapOrMat "right click to bring Map or Mat to active material editor slot" labels:#("map", "material") align:#right offset:[-175, 5]
		radiobuttons isSearch labels:#("search", "normal") align:#left
		edittext textBox "search"
		listbox mapBox "map" height:20
		listbox matBox "material" height:10
		
		on textBox changed txt do
		(
			mapMatchArr = #()
			mapMatchArr_str = #()
			
			mapBox.items = #()
			matBox.items = #()
			mapBox.caption = "map"
			matBox.caption = "material"
			mapBox.enabled = false
			matBox.enabled = false
			isSearch.state = 1
		)
		
		on textBox entered txt do
		(
			mapMatchArr = #()
			mapMatchArr_str = #()
			
			mapBox.items = #()
			matBox.items = #()
			mapBox.caption = "map"
			matBox.caption = "material"
			mapBox.enabled = true
			matBox.enabled = true
			isSearch.state = 1
			
			--matchPattern, case-insensitive
			local txtPattern = "*" + txt + "*"
			
			case bitOrMiss.state of
			(
				1:
				(
					--mapMatchArr = for i in mapBitmapArrUni where (findString i.fileName txt != undefined) collect i
					mapMatchArr = for i in mapBitmapArrUni where (matchPattern i.fileName pattern:txtPattern) collect i
				)
				2:
				(
					--mapMatchArr = for i in mapBitmapMissArrUni where (findString i.fileName txt != undefined) collect i
					mapMatchArr = for i in mapBitmapMissArrUni where (matchPattern i.fileName pattern:txtPattern) collect i
				)
				3:
				(
					--mapMatchArr = for i in mapTexmapMissArrUni where (findString i.fileName txt != undefined) collect i
					mapMatchArr = for i in mapTexmapMissArrUni where (matchPattern i.fileName pattern:txtPattern) collect i
				)
			)
			
			mapMatchArr_str = getArrayString mapMatchArr
			mapMatchArr_cnt = getUniqueArrayCount mapMatchArr mapBitmapArr
			
			mapBox.items = joinArrayString mapMatchArr_cnt mapMatchArr_str
			mapBox.caption = "map: " + mapMatchArr_str.count as string
		)
		
		on bitOrMiss changed state do
		(
			mapMatchArr = #()
			mapMatchArr_str = #()
			
			mapBox.items = #()
			matBox.items = #()
			mapBox.caption = "map"
			matBox.caption = "material"
			mapBox.enabled = true
			matBox.enabled = true
			
			textBox.text = ""
			isSearch.state = 2
			
			case state of
			(
				1:
				(
					mapBox.items = joinArrayString mapBitmapArrUni_cnt mapBitmapArrUni_str
					mapBox.caption = "map: " + mapBitmapArrUni_str.count as string
				)
				2:
				(
					mapBox.items = joinArrayString mapBitmapMissArrUni_cnt mapBitmapMissArrUni_str
					mapBox.caption = "map: " + mapBitmapMissArrUni_str.count as string
				)
				3:
				(
					mapBox.items = joinArrayString mapTexmapMissArrUni_cnt mapTexmapMissArrUni_str
					mapBox.caption = "map: " + mapTexmapMissArrUni_str.count as string
				)
			)
		)
		
		on mapBox selected itm do
		(
			matBoxArray = #()
			
			case isSearch.state of
			(
				1:
				(
					local refArray = refs.dependents mapMatchArr[itm]
					matBoxArray = for i in refArray where superClassOf i == material collect i
					matBox.items = for i in matBoxArray collect (i.name + " , " + (classOf i as string))
						
					local mapImg = renderMap mapMatchArr[itm] size:[40,40]
					mapIcon.images = #(mapImg,undefined,1,1,1,1,1)
						
					matBox.caption = "material: " + matBoxArray.count as string
				)
				2:
				(
				case bitOrMiss.state of
				(
					1:
					(
						local refArray = refs.dependents mapBitmapArrUni[itm]
						matBoxArray = for i in refArray where superClassOf i == material collect i
						matBox.items = for i in matBoxArray collect (i.name + " , " + (classOf i as string))
							
						local mapImg = renderMap mapBitmapArrUni[itm] size:[40,40]
						mapIcon.images = #(mapImg,undefined,1,1,1,1,1)
							
						matBox.caption = "material: " + matBoxArray.count as string
					)
					2:
					(
						local refArray = refs.dependents mapBitmapMissArrUni[itm]
						matBoxArray = for i in refArray where superClassOf i == material collect i
						matBox.items = for i in matBoxArray collect (i.name + " , " + (classOf i as string))
							
						local mapImg = renderMap mapBitmapMissArrUni[itm] size:[40,40]
						mapIcon.images = #(mapImg,undefined,1,1,1,1,1)
							
						matBox.caption = "material: " + matBoxArray.count as string
					)
					3:
					(
						local refArray = refs.dependents mapTexmapMissArrUni[itm]
						matBoxArray = for i in refArray where superClassOf i == material collect i
						matBox.items = for i in matBoxArray collect (i.name + " , " + (classOf i as string))
							
						local mapImg = renderMap mapTexmapMissArrUni[itm] size:[40,40]
						mapIcon.images = #(mapImg,undefined,1,1,1,1,1)
							
						matBox.caption = "material: " + matBoxArray.count as string
					)
				)
				)
			)
		)
		
		on mapBox rightClick itm do
		(
			if mapOrMat.state == 1 then --only work when 1
			(
				case isSearch.state of
				(
					1: --search mode
					(
						medit.PutMtlToMtlEditor mapMatchArr[itm] (medit.GetActiveMtlSlot())
					)
					2: --normal mode
					(
					case bitOrMiss.state of
					(
						1:
						(
							medit.PutMtlToMtlEditor mapBitmapArrUni[itm] (medit.GetActiveMtlSlot())
						)
						2:
						(
							medit.PutMtlToMtlEditor mapBitmapMissArrUni[itm] (medit.GetActiveMtlSlot())
						)
						3:
						(
							medit.PutMtlToMtlEditor mapTexmapMissArrUni[itm] (medit.GetActiveMtlSlot())
						)
					)
					)
				)
			)
		)
		
		on matBox rightClick itm do
		(
			if mapOrMat.state == 2 then --only work when 2
			(
				medit.PutMtlToMtlEditor matBoxArray[itm] (medit.GetActiveMtlSlot())
			)
		)
		
		on mapBrowser open do
		(
			if not MatEditor.isOpen() then MatEditor.open()
			isSearch.enabled = false
		)
		
		on mapBrowser close do
		(
			if MatEditor.isOpen() then MatEditor.close()
			resetGlobals()
			countEnd()
		)
	)
	
	createDialog mapBrowser pos:[200,200]
) --btn13 map browser

--btn14 fix vray mtl
on btn14 pressed do
(
	if (misClickPrevention str:"Only working on Vray materials, proceed?") then
	(
		if selection.count > 0 then
		(
			undo off
			
			--reset global
			matArray = #()
			matArrayUni = #()
			try(DestroyDialog matSetting) catch()
			
			--could be multiSubMaterial, undefined
			local objMatArray = for i in selection collect i.material
			
			--deal with multiSubMaterial and undefined
			for i in objMatArray do getMatRecursive i
			
			--only keep unique ones
			matArrayUni = makeUniqueArray matArray
			
			--rollout
			rollout matSetting "VrayMtl Material Setting" width:580 height:300
			(
				group "Parameter"
				(
				colorPicker cpDiff "diff color" color:(color 128 128 128) align:#left
				colorPicker cpRefl "refl color" color:(color 128 128 128) across:4
				spinner spReflGlos "refl glos" range:[0,1,0.6] type:#float scale:0.05 offset:[-20,0]
				spinner spReflDep "refl depth" range:[1,10,5] type:#integer offset:[-10,0]
				spinner spReflSub "refl subdiv" range:[1,16,8] type:#integer
				spinner spReflIOR "refl ior" range:[0,2,1.6] type:#float across:3 align:#left
				checkbox cbReflIOR "refl fresnel" checked:true offset:[-15,0]
				checkbox cbReflLock "fresnel lock" checked:true offset:[-78,0]
				colorPicker cpRefr "refr color" color:(color 0 0 0) across:4
				spinner spRefrGlos "refr glos" range:[0,1,1] type:#float scale:0.05 offset:[-20,0]
				spinner spRefrDep "refr depth" range:[1,10,5] type:#integer offset:[-10,0]
				spinner spRefrSub "refr subdiv" range:[1,16,8] type:#integer
				spinner spRefrIOR "refr ior" range:[0,2,1.6] type:#float width:82 align:#left
				spinner spDiff "diff" range:[0,100,100] type:#integer width:95 across:5 align:#left
				spinner spRefl "refl" range:[0,100,100] type:#integer width:95 align:#left
				spinner spRefr "refr" range:[0,100,100] type:#integer width:94 align:#left
				spinner spOpac "opac" range:[0,100,100] type:#integer width:90 align:#left
				spinner spBump "bump" range:[0,100,30] type:#integer width:88 align:#left
				)
				group "Exclude"
				(
				label lb "Exclude the following:" across:3 align:#left
				checkbox cbAll "check all" offset:[-70,0]
				checkbox cbPreset "exclude first 5" offset:[-180,0]
				checkbox cpDiffX "diff color" across:8
				checkbox cpReflX "ref color"
				checkbox spReflGlosX "refl glos"
				checkbox spReflDepX "refl depth"
				checkbox spReflSubX "refl subdiv" offset:[5,0]
				checkbox spReflIORX "refl ior" offset:[10,0]
				checkbox cbReflIORX "refl fresnel" offset:[-5,0]
				checkbox cbReflLockX "fresnel lock"
				checkbox cpRefrX "refr color" across: 5
				checkbox spRefrGlosX "refr glos"
				checkbox spRefrDepX "refr depth"
				checkbox spRefrSubX "refr subdiv"
				checkbox spRefrIORX "refr ior"
				checkbox spDiffX "diff mult" across: 5
				checkbox spReflX "refl mult"
				checkbox spRefrX "refr mult"
				checkbox spOpacX "opac mult"
				checkbox spBumpX "bump mult"
				)
				button btn "Apply Setting" align:#right
				
				on btn pressed do
				(
					--count start
					countStart()
					
					for i =1 to matArrayUni.count do
					(
						VRayMatSetting matArrayUni[i] cpDiff:cpDiff.color cpRefl:cpRefl.color spReflGlos:spReflGlos.value spReflDep:spReflDep.value spReflSub:spReflSub.value \
						spReflIOR:spReflIOR.value cbReflIOR:cbReflIOR.checked cbReflLock:cbReflLock.checked \
						cpRefr:cpRefr.color spRefrGlos:spRefrGlos.value spRefrDep:spRefrDep.value spRefrSub:spRefrSub.value spRefrIOR:spRefrIOR.value \
						spDiff:spDiff.value spRefl:spRefl.value spRefr:spRefr.value spOpac:spOpac.value spBump:spBump.value \
						cpDiffX:cpDiffX.checked cpReflX:cpReflX.checked spReflGlosX:spReflGlosX.checked spReflDepX:spReflDepX.checked spReflSubX:spReflSubX.checked \
						spReflIORX:spReflIORX.checked cbReflIORX:cbReflIORX.checked cbReflLockX:cbReflLockX.checked \
						cpRefrX:cpRefrX.checked spRefrGlosX:spRefrGlosX.checked spRefrDepX:spRefrDepX.checked spRefrSubX:spRefrSubX.checked spRefrIORX:spRefrIORX.checked \
						spDiffX:spDiffX.checked spReflX:spReflX.checked spRefrX:spRefrX.checked spOpacX:spOpacX.checked spBumpX:spBumpX.checked
						
						--count update
						countUpdate "mat: " i
					)
					
					MessageBox (matArrayUni.count as string + " materials worked on")
					
					--count end
					countEnd()
					
					--reset global
					matArray = #()
					matArrayUni = #()
					try(DestroyDialog matSetting) catch()
				)
				
				on matSetting close do
				(
					--reset global
					matArray = #()
					matArrayUni = #()
				)
				
				on cbAll changed arg do
				(
					--1 + 7 + 5 + 5
					cpDiffX.checked = arg
					
					cpReflX.checked = arg
					spReflGlosX.checked = arg
					spReflDepX.checked = arg
					spReflSubX.checked = arg
					spReflIORX.checked = arg
					cbReflIORX.checked = arg
					cbReflLockX.checked = arg
					
					cpRefrX.checked = arg
					spRefrGlosX.checked = arg
					spRefrDepX.checked = arg
					spRefrSubX.checked = arg
					spRefrIORX.checked = arg

					spDiffX.checked = arg
					spReflX.checked = arg
					spRefrX.checked = arg
					spOpacX.checked = arg
					spBumpX.checked = arg
					
					--1 + 7 + 5 + 5
					cpDiff.enabled = not arg
					
					cpRefl.enabled = not arg
					spReflGlos.enabled = not arg
					spReflDep.enabled = not arg
					spReflSub.enabled = not arg
					spReflIOR.enabled = not arg
					cbReflIOR.enabled = not arg
					cbReflLock.enabled = not arg
										
					cpRefr.enabled = not arg
					spRefrGlos.enabled = not arg
					spRefrDep.enabled = not arg
					spRefrSub.enabled = not arg
					spRefrIOR.enabled = not arg

					spDiff.enabled = not arg
					spRefl.enabled = not arg
					spRefr.enabled = not arg
					spOpac.enabled = not arg
					spBump.enabled = not arg
				)
				
				on cbPreset changed arg do
				(
					--button
					cpDiffX.checked = arg
					
					cpReflX.checked = arg
					spReflGlosX.checked = arg
					
					cpRefrX.checked = arg
					spRefrGlosX.checked = arg
					
					--actual
					cpDiff.enabled = not arg
					
					cpRefl.enabled = not arg
					spReflGlos.enabled = not arg
										
					cpRefr.enabled = not arg
					spRefrGlos.enabled = not arg
				)
				
				--1 + 7 + 5 + 5
				on cpDiffX changed arg do cpDiff.enabled = not arg
					
				on cpReflX changed arg do cpRefl.enabled = not arg
				on spReflGlosX changed arg do spReflGlos.enabled = not arg
				on spReflDepX changed arg do spReflDep.enabled = not arg
				on spReflSubX changed arg do spReflSub.enabled = not arg
				on spReflIORX changed arg do spReflIOR.enabled = not arg
				on cbReflIORX changed arg do cbReflIOR.enabled = not arg
				on cbReflLockX changed arg do cbReflLock.enabled = not arg
					
				on cpRefrX changed arg do cpRefr.enabled = not arg
				on spRefrGlosX changed arg do spRefrGlos.enabled = not arg
				on spRefrDepX changed arg do spRefrDep.enabled = not arg
				on spRefrSubX changed arg do spRefrSub.enabled = not arg
				on spRefrIORX changed arg do spRefrIOR.enabled = not arg

				on spDiffX changed arg do spDiff.enabled = not arg
				on spReflX changed arg do spRefl.enabled = not arg
				on spRefrX changed arg do spRefr.enabled = not arg
				on spOpacX changed arg do spOpac.enabled = not arg
				on spBumpX changed arg do spBump.enabled = not arg

			)
			
			createDialog matSetting pos:[200,200]
		)
		else
		(
			MessageBox "Nothing selected. Nothing was done."
		)
	)
	else --misClick
	(
		MessageBox "Nothing was done"
	)
) --btn14 fix vray mtl

--btn18 find noncorona
on btn18 pressed do
(
	if misClickPrevention str:"This will find and select objects with non Corona Materials, proceed?" then
	(
		undo off
		
		matArray = #()
		local matLocalArray = #()
		local matLocalArraySS = StringStream ""
		local objArray = #()
		
		--1 scenmaterials
		--UpdateSceneMaterialLib()
		getMatRecursiveScene()

		--2 solo mats
		local maCnt = matArray.count
		for i = 1 to maCnt do
		(
			if classOf matArray[i] != CoronaPhysicalMtl and classOf matArray[i] != CoronaLegacyMtl and \
				classOf matArray[i] != CoronaLightMtl and superclassOf matArray[i] != textureMap then
			(
				append matLocalArray matArray[i]
				format "%\n" matArray[i] to: matLocalArraySS
			)
			countUpdate "solo mat: " i
		)
		
		for k in matLocalArray do
		(
			local refArray = refs.dependents k
			local refGeoArray = for o in refArray where ((superClassOf o == shape) or (superClassOf o == GeometryClass)) and \
										classOf o != ChaosScatter collect o
			join objArray refGeoArray
		)
		
		if matLocalArraySS as string != "" then
		(
			MessageBox (matLocalArraySS as string)
			select objArray
			countEnd()
		)
		else
		(
			MessageBox "All materials were checked"
			countEnd()
		)

		matArray = #()
	)
	else --misClick
	(
		MessageBox "Nothing was done"
	)
) --btn18 find noncorona

--btn22 check output
on btn22 pressed do
(
	if misClickPrevention str:"Might be slow because of checking gamma, Save Save!" then
	(
		undo off
		
		--0 clear globals
		try(DestroyDialog mapChecker) catch()
		resetGlobals()
		UpdateSceneMaterialLib()
		
		--1 Bitmaptexture
		--this will exclude Missing_TextureMap
		--but cannot open bitmap and cannot check gamma if doesFileExist == false
		mapBitmapArr = getClassInstances BitmapTexture
		
		fn checkGamma m =
		(
			--make sure file exist, else checked by dosefileexist below
			if doesFileExist m.fileName then
			(
				--in case of normal map or roughness map
				if MatchPattern m.fileName pattern:"*nrm*" or MatchPattern m.fileName pattern:"*normal*" or MatchPattern m.fileName pattern:"*roughness*" then
				(
					--data map should have 1.0 gamma
					if m.bitmap.inputGamma != 1.0 then true else false
				)
				--in case of not normal map
				else
				(
					--should have gamma #auto
					if m.bitmap.inputGamma != #auto then true else false
				)
			)
			else
			(
				false
			)
		)
		
		--2 problem
		mapBitmapArrUni = for i in mapBitmapArr where i.output.output_amount != 1.0 or i.output.RGB_Level != 1.0 or i.output.RGB_Offset != 0.0 \
			or i.output.Bump_Amount != 1.0 or i.output.invert != false or i.output.clamp != false or i.output.alphaFromRGB != false \
			or (checkGamma i) or not(doesFileExist i.fileName) collect i
		
		--3 rollout
		rollout mapChecker "Map Checker"  width:550 height:480
		(
			listbox mapBox "map - right click to bring to active material editor slot" height:20
			label lb "problem" align:#left
			label issueBox style_sunkenedge:true width:260 height:110 across:2 align:#left
			label refBox style_sunkenedge:true width:260 height:110 align:#right
			checkbox cb "fix all output" across:5 align:#left
			label lb1 "filter:" offset:[-30,0]
			radiobuttons rbFilter labels:#("n/a","0.01","0.2","0.5") columns:4 offset:[-25,0]
			label lb2 "gamma:" offset:[-10,0]
			radiobuttons rbGamma labels:#("n/a","#auto","1.0") columns:3 offset:[-10,0]
			button btn "set" width:80 height:30 align:#right
			
			on mapBox selected itm do
			(
				local ss = StringStream ""
				
				local a = try(mapBitmapArrUni[itm].bitmap.inputGamma)catch()
				local b = try(mapBitmapArrUni[itm].bitmap.gamma)catch()
				local c =				
				if mapBitmapArrUni[itm].fileName.count > 45 then
				(
					(substring mapBitmapArrUni[itm].fileName 1 40) + "..\n" + (substring mapBitmapArrUni[itm].fileName (mapBitmapArrUni[itm].fileName.count-45) -1)
				)
				else
				(
					(substring mapBitmapArrUni[itm].fileName 1 40) + "..\n" + (substring mapBitmapArrUni[itm].fileName 1 -1)
				)
					
				if not doesFileExist(mapBitmapArrUni[itm].fileName) then
				(
					c = "Invalid: " + c
				)
				
				format ("Invert: %   Output Amount: %\nClamp: %   RGB Offset: %\nAlpha: %    RGB Level: %\n                       Bump Amount: %\n" +
					"Gamma: %   Value: %\nBitmap: %") \
				mapBitmapArrUni[itm].output.invert mapBitmapArrUni[itm].output.output_amount \
				mapBitmapArrUni[itm].output.clamp mapBitmapArrUni[itm].output.RGB_Offset \
				mapBitmapArrUni[itm].output.alphaFromRGB mapBitmapArrUni[itm].output.RGB_Level mapBitmapArrUni[itm].output.Bump_Amount \
				a b c \
				to: ss
					
				issueBox.text = ss as string
			)
			
			on mapBox rightClick itm do
			(
				medit.PutMtlToMtlEditor mapBitmapArrUni[itm] (medit.GetActiveMtlSlot())
			)
			
			on mapChecker open do
			(
				mapBox.items = for i in mapBitmapArrUni collect (i as string)
				refBox.text = "Invert: false   Output Amount: 1.0\nClamp: false   RGB Offset: 0.0\nAlpha: false    RGB Level: 1.0\n                       " +
				"Bump Amount: 1.0\nGamma: #auto   Value: 2.2"
				refBox.enabled = false
			)
			
			on mapChecker close do
			(
				resetGlobals()
			)
			
			on btn pressed do
			(
				--global no change boolean
				local isChanged = false
				
				if mapBox.selection > 0 and mapBitmapArrUni[mapBox.selection] != undefined and doesFileExist mapBitmapArrUni[mapBox.selection].fileName then
				(
					local m = mapBitmapArrUni[mapBox.selection]

					--start
					if cb.checked then
					(
						m.output.output_amount = 1.0
						m.output.RGB_Level = 1.0
						m.output.RGB_Offset = 0.0
						m.output.Bump_Amount = 1.0
						
						isChanged = true
					)
					
					case rbFilter.state of
					(
						1:
						(
						)
						2:
						(
							m.coords.blur = 0.01
							isChanged = true
						)
						3:
						(
							m.coords.blur = 0.2
							isChanged = true
						)
						4:
						(
							m.coords.blur = 0.5
							isChanged = true
						)
					)
					
					case rbGamma.state of
					(
						1:
						(
						)
						2:
						(
							m.bitmap = openBitmap m.fileName gamma:#auto
							isChanged = true
						)
						3:
						(
							m.bitmap = openBitmap m.fileName gamma:1.0
							isChanged = true
						)
					)
					--done
				)
				
				--global no change boolean
				if not isChanged then
				(
					messageBox "no change"
				)
			)
		)
		
		createDialog mapChecker pos:[200,200]
	)
	else --misClick
	(
		MessageBox "Nothing was done"
	)
) --btn22 check output

on btn23 pressed do
(
	if misClickPrevention str:"This will reset the current material slot, proceed?" then
	(
		undo off
		
		local m = medit.GetCurMtl()
		local tDiffuse = Bitmaptexture name:"diff" filtering:0
		tDiffuse.coords.blur = 0.01
		local tRough = Bitmaptexture name:"rough" filtering:0
		tRough.coords.blur = 0.2
		local tBump = VRayNormalMap name:"bump"
		local tNormal = Bitmaptexture name:"nrm" filtering:0
		tNormal.coords.blur = 1.0
		setSubTexmap tBump 1 tNormal
		
		if classOf m == VRayMtl then
		(
			m.texmap_diffuse = tDiffuse
			m.reflection = color 255 255 255
			m.brdf_useRoughness = true
			m.texmap_reflectionGlossiness = tRough
			m.texmap_bump = tBump
			m.texmap_bump_multiplier = 100
		)
	
	)
	else --misClick
	(
		MessageBox "Nothing was done"
	)
)

) --F

--G
rollout viewPo "Import"
(
button btn15 "import rvt fbx" across:2 align:#left
button btn16 "import other" align:#right
	
on btn15 pressed do
(
	if misClickPrevention str:"This will delete all but geometries, for revit fbx only, proceed?" then
	(
		viewPoSetting()
		viewPoSetting()
		
		l = delete lights
		c = delete cameras
		h = delete helpers
		
		for i in objects do
		(
			i.material = undefined
			i.wirecolor = [(random 0 255),(random 0 255),(random 0 255)] as color
			ResetXForm i
			CenterPivot i
			convertToMesh i
		)
		
		MessageBox (l as string + " lights, " + c as string + " cameras, " + h as string + " helpers deleted")
	)
	else --misClick
	(
		MessageBox "Nothing was done"
	)
) --btn15

on btn16 pressed do
(
	if (misClickPrevention str:"This will delete all but geometries, proceed?") then
	(
		viewPoSetting()
		viewPoSetting()
		
		l = delete lights
		c = delete cameras
		h = delete helpers
		
		for i in objects do
		(
			i.material = undefined
			i.wirecolor = [(random 0 255),(random 0 255),(random 0 255)] as color
			CenterPivot i
		)
		
		MessageBox (l as string + " lights, " + c as string + " cameras, " + h as string + " helpers deleted")
	)
	else --misClick
	(
		MessageBox "Nothing was done"
	)
) --btn16
	
) --G

--H
rollout miscU "Misc"
(
button btn17 "check mod" across:3 align:#left
button btn19 "dir" align:#center offset:[15,0]
button btn20 "help" align:#right
button btn21 "ref" across:2 align:#left
button btn23 "proxy display mode" align:#right
spinner pr "mode" range:[0,4,4] type:#integer fieldWidth:30 align:#right

--btn17 check mod
on btn17 pressed do
(
	if misClickPrevention() then
	(
		local modSS = StringStream ""
		local objArray = #()

		--count start
		countStart()
		
		--start
		local modCnt = objects.count
		for i = 1 to modCnt do
		(
			if objects[i].modifiers.count > 0 then
			(
				for j = 1 to objects[i].modifiers.count do
				(
					if objects[i].modifiers[j].enabled == false then
					(
						format "%, %, off\n" objects[i].name objects[i].modifiers[j].name to: modSS
						append objArray objects[i]
					)
				)
			)
			
			--count update
			countUpdate "obj: " i
				)

		if modSS as string != "" then
		(
			MessageBox (modSS as string)
			select objArray
			
			--count end
			countEnd()
		)
		else
		(
			MessageBox "All modifiers are good"
			
			--count end
			countEnd()
		)
	)
	else --misClick
	(
		MessageBox "Nothing was done"
	)
) --btn17 check mod

--btn19 dir
on btn19 pressed do
(
	ShellLaunch sysInfo.currentdir ""
) --btn19 dir

--btn20 help
on btn20 pressed do
(
	shelllaunch "msedge.exe" "https://help.autodesk.com/view/MAXDEV/2022/ENU/?guid=GUID-F039181A-C072-4469-A329-AE60FF7535E7"
) --btn20 help

on btn21 pressed do
(
	try(DestroyDialog roSize) catch()
	
	rollout roSize "size"
	(
		spinner sp "size" range:[1,20,2] width:80 type:#float scale:0.1 across:2 offset:[10,0]
		label lb "feet"
		edittext et "name" text:"0 ref plane"
		checkbox cb "bring to medit" across:2
		button btn "create" offset:[15,-3]
		
		--only work when button is pressed
		on btn pressed do
		(
			local refR = Rectangle name:et.text position:[0,0,0] length:(sp.value*12) width:(sp.value*12)
			local refBit = Bitmaptexture name:"refBit" filename:"c:\\a.jpg"
			local refM = Standardmaterial name:"refM" diffuseMap:refBit showInViewport:true opacity:50
			local w, h
			refM.diffuseMap.coords.blur = 0.01
			refM.diffuseMap.coords.U_Tile = false
			refM.diffuseMap.coords.V_Tile = false
			
			--prepared the material
			UpdateSceneMaterialLib()
			for i in sceneMaterials do
			(
				if i.name == refM.name then
				(
					assignNewName refM
				)
			)
			
			--prepare the bitmap
			local f = getOpenFileName caption:"Open bitmap:" filename:(sysInfo.currentdir + "\\a.jpg") types:"png(*.png)|*.png|jpg(*.jpg)|*.jpg|All|*.*|"
			
			if f != undefined then
			(
				refBit.filename = f
				w = try(refBit.bitmap.width) catch()
				if w != undefined then
				(
					h = sp.value * 12 / w * refBit.bitmap.height
				)
				else
				(
					messageBox "bitmap invalid"
					h = sp.value * 12
				)
			)
			else
			(
				messageBox "bitmap invalid"
				h = sp.value * 12
			)
			
			--assign material
			refR.material = refM
			
			--extra
			if cb.checked then
			(
				medit.PutMtlToMtlEditor refM (medit.GetActiveMtlSlot())
			)
			
			--add modifier
			addModifier refR (Uvwmap maptype:0 width:(sp.value*12) length:h)
			
			--select and zoom
			select refR
			max zoomext sel
			
			DestroyDialog roSize
		) --on btn pressed do
	)
	
	CreateDialog roSize pos:[650,680]
)

--btn23 corona proxy display mode
on btn23 pressed do
(
	if selection.count > 0 then
	(
		for i in selection where classOf i == CProxy do
		(
			--toggle mode
			if pr.value == 4 then
			(
				if i.previzType == 0 then
				(
					i.previzType = 1
				)
				else if i.previzType == 1 then
				(
					i.previzType = 2
				)
				else if i.previzType == 2 then
				(
					i.previzType = 3
				)
				else if i.previzType == 3 then
				(
					i.previzType = 0
				)
			)
			--select mode
			else
			(
				i.previzType = pr.value
			)
		)
	)
	else
	(
		MessageBox "Nothing selected. Nothing was done."
	)
) --btn23 corona proxy display mode

) --H

try(closeRolloutFloater nf) catch()
nf = newRolloutFloater "TOOL" 200 500
addRollout mID nf --A
addRollout layerFix nf --B
addRollout reSetting nf rolledUp:true --D
addRollout objDummy nf rolledUp:true --C
addRollout astTrack nf rolledUp:true --E
addRollout mapMissing nf --F
addRollout viewPo nf rolledUp:true --G
addRollout miscU nf --H
