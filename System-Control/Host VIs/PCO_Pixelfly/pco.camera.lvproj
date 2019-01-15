<?xml version='1.0' encoding='UTF-8'?>
<Project Type="Project" LVVersion="12008004">
	<Item Name="My Computer" Type="My Computer">
		<Property Name="server.app.propertiesEnabled" Type="Bool">true</Property>
		<Property Name="server.control.propertiesEnabled" Type="Bool">true</Property>
		<Property Name="server.tcp.enabled" Type="Bool">false</Property>
		<Property Name="server.tcp.port" Type="Int">0</Property>
		<Property Name="server.tcp.serviceName" Type="Str">My Computer/VI-Server</Property>
		<Property Name="server.tcp.serviceName.default" Type="Str">My Computer/VI-Server</Property>
		<Property Name="server.vi.callsEnabled" Type="Bool">true</Property>
		<Property Name="server.vi.propertiesEnabled" Type="Bool">true</Property>
		<Property Name="specify.custom.address" Type="Bool">false</Property>
		<Item Name="pco.camera" Type="Folder">
			<Item Name="APIManagement.llb" Type="Folder">
				<Item Name="AddBuffer.vi" Type="VI" URL="../APIManagement.llb/AddBuffer.vi"/>
				<Item Name="AddBufferEX.vi" Type="VI" URL="../APIManagement.llb/AddBufferEX.vi"/>
				<Item Name="AllocateBuffer.vi" Type="VI" URL="../APIManagement.llb/AllocateBuffer.vi"/>
				<Item Name="CamLinkSetImageParameters.vi" Type="VI" URL="../APIManagement.llb/CamLinkSetImageParameters.vi"/>
				<Item Name="CancelImages.vi" Type="VI" URL="../APIManagement.llb/CancelImages.vi"/>
				<Item Name="CheckDeviceAvailability.vi" Type="VI" URL="../APIManagement.llb/CheckDeviceAvailability.vi"/>
				<Item Name="Cleanup.vi" Type="VI" URL="../APIManagement.llb/Cleanup.vi"/>
				<Item Name="CloseCamera.vi" Type="VI" URL="../APIManagement.llb/CloseCamera.vi"/>
				<Item Name="FreeBuffer.vi" Type="VI" URL="../APIManagement.llb/FreeBuffer.vi"/>
				<Item Name="GetBufferStatus.vi" Type="VI" URL="../APIManagement.llb/GetBufferStatus.vi"/>
				<Item Name="GetImage.vi" Type="VI" URL="../APIManagement.llb/GetImage.vi"/>
				<Item Name="GetImageBuffer.vi" Type="VI" URL="../APIManagement.llb/GetImageBuffer.vi"/>
				<Item Name="GetImageBuffer2D.vi" Type="VI" URL="../APIManagement.llb/GetImageBuffer2D.vi"/>
				<Item Name="GetImageEX.vi" Type="VI" URL="../APIManagement.llb/GetImageEX.vi"/>
				<Item Name="GetInfoString.vi" Type="VI" URL="../APIManagement.llb/GetInfoString.vi"/>
				<Item Name="GetPendingBuffer.vi" Type="VI" URL="../APIManagement.llb/GetPendingBuffer.vi"/>
				<Item Name="GetTransferParameters.vi" Type="VI" URL="../APIManagement.llb/GetTransferParameters.vi"/>
				<Item Name="Handle_Edge_Pixelrate.vi" Type="VI" URL="../APIManagement.llb/Handle_Edge_Pixelrate.vi"/>
				<Item Name="InitLibrary.vi" Type="VI" URL="../APIManagement.llb/InitLibrary.vi"/>
				<Item Name="OpenCamera.vi" Type="VI" URL="../APIManagement.llb/OpenCamera.vi"/>
				<Item Name="OpenCameraEx.vi" Type="VI" URL="../APIManagement.llb/OpenCameraEx.vi"/>
				<Item Name="Reset_SDK_Lib.vi" Type="VI" URL="../APIManagement.llb/Reset_SDK_Lib.vi"/>
				<Item Name="SetTransferParameters.vi" Type="VI" URL="../APIManagement.llb/SetTransferParameters.vi"/>
				<Item Name="WaitForBuffer.vi" Type="VI" URL="../APIManagement.llb/WaitForBuffer.vi"/>
			</Item>
			<Item Name="BufferData.llb" Type="Folder">
				<Item Name="ClearHotPixelList.vi" Type="VI" URL="../BufferData.llb/ClearHotPixelList.vi"/>
				<Item Name="GetBitAlignment.vi" Type="VI" URL="../BufferData.llb/GetBitAlignment.vi"/>
				<Item Name="GetHotPixelCorrectionMode.vi" Type="VI" URL="../BufferData.llb/GetHotPixelCorrectionMode.vi"/>
				<Item Name="GetImageSegmentSettings.vi" Type="VI" URL="../BufferData.llb/GetImageSegmentSettings.vi"/>
				<Item Name="GetNumberOfImagesInSegment.vi" Type="VI" URL="../BufferData.llb/GetNumberOfImagesInSegment.vi"/>
				<Item Name="GetSegmentStructure.vi" Type="VI" URL="../BufferData.llb/GetSegmentStructure.vi"/>
				<Item Name="ReadHotPixelList.vi" Type="VI" URL="../BufferData.llb/ReadHotPixelList.vi"/>
				<Item Name="SetBitAlignment.vi" Type="VI" URL="../BufferData.llb/SetBitAlignment.vi"/>
				<Item Name="SetHotPixelCorrectionMode.vi" Type="VI" URL="../BufferData.llb/SetHotPixelCorrectionMode.vi"/>
				<Item Name="WriteHotPixelList.vi" Type="VI" URL="../BufferData.llb/WriteHotPixelList.vi"/>
			</Item>
			<Item Name="GeneralControlStatus.llb" Type="Folder">
				<Item Name="colorpattern.ctl" Type="VI" URL="../GeneralControlStatus.llb/colorpattern.ctl"/>
				<Item Name="ErrorManager.vi" Type="VI" URL="../GeneralControlStatus.llb/ErrorManager.vi"/>
				<Item Name="FormatHWDESC.vi" Type="VI" URL="../GeneralControlStatus.llb/FormatHWDESC.vi"/>
				<Item Name="FormatSoftwareDesc.vi" Type="VI" URL="../GeneralControlStatus.llb/FormatSoftwareDesc.vi"/>
				<Item Name="GetCameraHealthStatus.vi" Type="VI" URL="../GeneralControlStatus.llb/GetCameraHealthStatus.vi"/>
				<Item Name="GetCameraNamevi.vi" Type="VI" URL="../GeneralControlStatus.llb/GetCameraNamevi.vi"/>
				<Item Name="GetCameraSetup.vi" Type="VI" URL="../GeneralControlStatus.llb/GetCameraSetup.vi"/>
				<Item Name="GetCameraType.vi" Type="VI" URL="../GeneralControlStatus.llb/GetCameraType.vi"/>
				<Item Name="GetGeneral.vi" Type="VI" URL="../GeneralControlStatus.llb/GetGeneral.vi"/>
				<Item Name="GetTemperatures.vi" Type="VI" URL="../GeneralControlStatus.llb/GetTemperatures.vi"/>
				<Item Name="InitiateSelfTestProcedure.vi" Type="VI" URL="../GeneralControlStatus.llb/InitiateSelfTestProcedure.vi"/>
				<Item Name="RebootCamera.vi" Type="VI" URL="../GeneralControlStatus.llb/RebootCamera.vi"/>
				<Item Name="ResetSettingsToDefault.vi" Type="VI" URL="../GeneralControlStatus.llb/ResetSettingsToDefault.vi"/>
				<Item Name="SetCameraSetup.vi" Type="VI" URL="../GeneralControlStatus.llb/SetCameraSetup.vi"/>
				<Item Name="SetTimeouts.vi" Type="VI" URL="../GeneralControlStatus.llb/SetTimeouts.vi"/>
				<Item Name="StripCamType.vi" Type="VI" URL="../GeneralControlStatus.llb/StripCamType.vi"/>
			</Item>
			<Item Name="RecordingControl.llb" Type="Folder">
				<Item Name="ArmCamera.vi" Type="VI" URL="../RecordingControl.llb/ArmCamera.vi"/>
				<Item Name="GetAcquireEnableSignalStatus.vi" Type="VI" URL="../RecordingControl.llb/GetAcquireEnableSignalStatus.vi"/>
				<Item Name="GetAcquireMode.vi" Type="VI" URL="../RecordingControl.llb/GetAcquireMode.vi"/>
				<Item Name="GetRecorderSubmode.vi" Type="VI" URL="../RecordingControl.llb/GetRecorderSubmode.vi"/>
				<Item Name="GetRecordingState.vi" Type="VI" URL="../RecordingControl.llb/GetRecordingState.vi"/>
				<Item Name="GetStorageMode.vi" Type="VI" URL="../RecordingControl.llb/GetStorageMode.vi"/>
				<Item Name="GetTimeStampMode.vi" Type="VI" URL="../RecordingControl.llb/GetTimeStampMode.vi"/>
				<Item Name="SetAcquireMode.vi" Type="VI" URL="../RecordingControl.llb/SetAcquireMode.vi"/>
				<Item Name="SetDateTime.vi" Type="VI" URL="../RecordingControl.llb/SetDateTime.vi"/>
				<Item Name="SetRecorderSubmode.vi" Type="VI" URL="../RecordingControl.llb/SetRecorderSubmode.vi"/>
				<Item Name="SetRecordingState.vi" Type="VI" URL="../RecordingControl.llb/SetRecordingState.vi"/>
				<Item Name="SetStorageMode.vi" Type="VI" URL="../RecordingControl.llb/SetStorageMode.vi"/>
				<Item Name="SetTimeStampMode.vi" Type="VI" URL="../RecordingControl.llb/SetTimeStampMode.vi"/>
			</Item>
			<Item Name="Sensor.llb" Type="Folder">
				<Item Name="GetActiveLookupTable.vi" Type="VI" URL="../Sensor.llb/GetActiveLookupTable.vi"/>
				<Item Name="GetADCOperation.vi" Type="VI" URL="../Sensor.llb/GetADCOperation.vi"/>
				<Item Name="GetBinning.vi" Type="VI" URL="../Sensor.llb/GetBinning.vi"/>
				<Item Name="GetConversionFactor.vi" Type="VI" URL="../Sensor.llb/GetConversionFactor.vi"/>
				<Item Name="GetCoolingSetpointTemperature.vi" Type="VI" URL="../Sensor.llb/GetCoolingSetpointTemperature.vi"/>
				<Item Name="GetDescription.vi" Type="VI" URL="../Sensor.llb/GetDescription.vi"/>
				<Item Name="GetDescriptionEX.vi" Type="VI" URL="../Sensor.llb/GetDescriptionEX.vi"/>
				<Item Name="GetDoubleImageMode.vi" Type="VI" URL="../Sensor.llb/GetDoubleImageMode.vi"/>
				<Item Name="GetHWIOSignalCount.vi" Type="VI" URL="../Sensor.llb/GetHWIOSignalCount.vi"/>
				<Item Name="GetHWIOSignalDescriptor.vi" Type="VI" URL="../Sensor.llb/GetHWIOSignalDescriptor.vi"/>
				<Item Name="GetIRSensitivity.vi" Type="VI" URL="../Sensor.llb/GetIRSensitivity.vi"/>
				<Item Name="GetLookupTableInfo.vi" Type="VI" URL="../Sensor.llb/GetLookupTableInfo.vi"/>
				<Item Name="GetNoiseFilterMode.vi" Type="VI" URL="../Sensor.llb/GetNoiseFilterMode.vi"/>
				<Item Name="GetOffsetMode.vi" Type="VI" URL="../Sensor.llb/GetOffsetMode.vi"/>
				<Item Name="GetPixelRate.vi" Type="VI" URL="../Sensor.llb/GetPixelRate.vi"/>
				<Item Name="GetROI.vi" Type="VI" URL="../Sensor.llb/GetROI.vi"/>
				<Item Name="GetSensorFormat.vi" Type="VI" URL="../Sensor.llb/GetSensorFormat.vi"/>
				<Item Name="GetSizes.vi" Type="VI" URL="../Sensor.llb/GetSizes.vi"/>
				<Item Name="SetActiveLookupTable.vi" Type="VI" URL="../Sensor.llb/SetActiveLookupTable.vi"/>
				<Item Name="SetADCOperation.vi" Type="VI" URL="../Sensor.llb/SetADCOperation.vi"/>
				<Item Name="SetBinning.vi" Type="VI" URL="../Sensor.llb/SetBinning.vi"/>
				<Item Name="SetConversionFactor.vi" Type="VI" URL="../Sensor.llb/SetConversionFactor.vi"/>
				<Item Name="SetCoolingSetpointTemperature.vi" Type="VI" URL="../Sensor.llb/SetCoolingSetpointTemperature.vi"/>
				<Item Name="SetDoubleImageMode.vi" Type="VI" URL="../Sensor.llb/SetDoubleImageMode.vi"/>
				<Item Name="SetIRSensitivity.vi" Type="VI" URL="../Sensor.llb/SetIRSensitivity.vi"/>
				<Item Name="SetNoiseFilterMode.vi" Type="VI" URL="../Sensor.llb/SetNoiseFilterMode.vi"/>
				<Item Name="SetOffsetMode.vi" Type="VI" URL="../Sensor.llb/SetOffsetMode.vi"/>
				<Item Name="SetPixelRate.vi" Type="VI" URL="../Sensor.llb/SetPixelRate.vi"/>
				<Item Name="SetROI.vi" Type="VI" URL="../Sensor.llb/SetROI.vi"/>
				<Item Name="SetSensorFormat.vi" Type="VI" URL="../Sensor.llb/SetSensorFormat.vi"/>
			</Item>
			<Item Name="Storage.llb" Type="Folder">
				<Item Name="ClearRAMSegment.vi" Type="VI" URL="../Storage.llb/ClearRAMSegment.vi"/>
				<Item Name="GetActiveRAMSegment.vi" Type="VI" URL="../Storage.llb/GetActiveRAMSegment.vi"/>
				<Item Name="GetCameraRAMSize.vi" Type="VI" URL="../Storage.llb/GetCameraRAMSize.vi"/>
				<Item Name="GetCamRAMSegmentSize.vi" Type="VI" URL="../Storage.llb/GetCamRAMSegmentSize.vi"/>
				<Item Name="SetActiveRAMSegment.vi" Type="VI" URL="../Storage.llb/SetActiveRAMSegment.vi"/>
				<Item Name="SetCamRAMSegmentSize.vi" Type="VI" URL="../Storage.llb/SetCamRAMSegmentSize.vi"/>
			</Item>
			<Item Name="TimingControl.llb" Type="Folder">
				<Item Name="ForceTrigger.vi" Type="VI" URL="../TimingControl.llb/ForceTrigger.vi"/>
				<Item Name="GetBusyStatus.vi" Type="VI" URL="../TimingControl.llb/GetBusyStatus.vi"/>
				<Item Name="GetCOCRunTime.vi" Type="VI" URL="../TimingControl.llb/GetCOCRunTime.vi"/>
				<Item Name="GetDelayExposureTime.vi" Type="VI" URL="../TimingControl.llb/GetDelayExposureTime.vi"/>
				<Item Name="GetDelayExposureTimeTable.vi" Type="VI" URL="../TimingControl.llb/GetDelayExposureTimeTable.vi"/>
				<Item Name="GetExpTrigSignalStatus.vi" Type="VI" URL="../TimingControl.llb/GetExpTrigSignalStatus.vi"/>
				<Item Name="GetFPSExposureMode.vi" Type="VI" URL="../TimingControl.llb/GetFPSExposureMode.vi"/>
				<Item Name="GetFrameRate.vi" Type="VI" URL="../TimingControl.llb/GetFrameRate.vi"/>
				<Item Name="GetHWIOSignal.vi" Type="VI" URL="../TimingControl.llb/GetHWIOSignal.vi"/>
				<Item Name="GetModulationMode.vi" Type="VI" URL="../TimingControl.llb/GetModulationMode.vi"/>
				<Item Name="GetPowerDownMode.vi" Type="VI" URL="../TimingControl.llb/GetPowerDownMode.vi"/>
				<Item Name="GetTrigger.vi" Type="VI" URL="../TimingControl.llb/GetTrigger.vi"/>
				<Item Name="GetUserPowerDownTime.vi" Type="VI" URL="../TimingControl.llb/GetUserPowerDownTime.vi"/>
				<Item Name="SetDelayExposureTime.vi" Type="VI" URL="../TimingControl.llb/SetDelayExposureTime.vi"/>
				<Item Name="SetDelayExposureTimeTable.vi" Type="VI" URL="../TimingControl.llb/SetDelayExposureTimeTable.vi"/>
				<Item Name="SetFPSExposureMode.vi" Type="VI" URL="../TimingControl.llb/SetFPSExposureMode.vi"/>
				<Item Name="SetFrameRate.vi" Type="VI" URL="../TimingControl.llb/SetFrameRate.vi"/>
				<Item Name="SetModulationMode.vi" Type="VI" URL="../TimingControl.llb/SetModulationMode.vi"/>
				<Item Name="SetPowerDownMode.vi" Type="VI" URL="../TimingControl.llb/SetPowerDownMode.vi"/>
				<Item Name="SetTrigger.vi" Type="VI" URL="../TimingControl.llb/SetTrigger.vi"/>
				<Item Name="SetUserPowerDownTime.vi" Type="VI" URL="../TimingControl.llb/SetUserPowerDownTime.vi"/>
			</Item>
			<Item Name="Grab images from pco.edge or pco.pixelfly USB.vi" Type="VI" URL="../Grab images from pco.edge or pco.pixelfly USB.vi"/>
			<Item Name="pcolabview.dll" Type="Document" URL="../pcolabview.dll"/>
			<Item Name="Record and playback example for pco.cameras with CamRam.vi" Type="VI" URL="../Record and playback example for pco.cameras with CamRam.vi"/>
			<Item Name="SC2_Cam.dll" Type="Document" URL="../SC2_Cam.dll"/>
			<Item Name="Simple Grab image.vi" Type="VI" URL="../Simple Grab image.vi"/>
			<Item Name="Switch mode for pco.edge.vi" Type="VI" URL="../Switch mode for pco.edge.vi"/>
			<Item Name="WaitFor2DBufferExample.vi" Type="VI" URL="../WaitFor2DBufferExample.vi"/>
			<Item Name="WaitForBufferExample.vi" Type="VI" URL="../WaitForBufferExample.vi"/>
		</Item>
		<Item Name="Abhängigkeiten" Type="Dependencies">
			<Item Name="vi.lib" Type="Folder">
				<Item Name="BuildHelpPath.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/BuildHelpPath.vi"/>
				<Item Name="Check Special Tags.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Check Special Tags.vi"/>
				<Item Name="Clear Errors.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Clear Errors.vi"/>
				<Item Name="Convert property node font to graphics font.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Convert property node font to graphics font.vi"/>
				<Item Name="Details Display Dialog.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Details Display Dialog.vi"/>
				<Item Name="DialogType.ctl" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/DialogType.ctl"/>
				<Item Name="DialogTypeEnum.ctl" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/DialogTypeEnum.ctl"/>
				<Item Name="Error Code Database.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Error Code Database.vi"/>
				<Item Name="ErrWarn.ctl" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/ErrWarn.ctl"/>
				<Item Name="eventvkey.ctl" Type="VI" URL="/&lt;vilib&gt;/event_ctls.llb/eventvkey.ctl"/>
				<Item Name="Find Tag.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Find Tag.vi"/>
				<Item Name="Format Message String.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Format Message String.vi"/>
				<Item Name="General Error Handler CORE.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/General Error Handler CORE.vi"/>
				<Item Name="General Error Handler.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/General Error Handler.vi"/>
				<Item Name="Get String Text Bounds.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Get String Text Bounds.vi"/>
				<Item Name="Get Text Rect.vi" Type="VI" URL="/&lt;vilib&gt;/picture/picture.llb/Get Text Rect.vi"/>
				<Item Name="GetHelpDir.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/GetHelpDir.vi"/>
				<Item Name="GetRTHostConnectedProp.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/GetRTHostConnectedProp.vi"/>
				<Item Name="Longest Line Length in Pixels.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Longest Line Length in Pixels.vi"/>
				<Item Name="LVBoundsTypeDef.ctl" Type="VI" URL="/&lt;vilib&gt;/Utility/miscctls.llb/LVBoundsTypeDef.ctl"/>
				<Item Name="Not Found Dialog.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Not Found Dialog.vi"/>
				<Item Name="Search and Replace Pattern.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Search and Replace Pattern.vi"/>
				<Item Name="Set Bold Text.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Set Bold Text.vi"/>
				<Item Name="Set String Value.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Set String Value.vi"/>
				<Item Name="Simple Error Handler.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Simple Error Handler.vi"/>
				<Item Name="subTimeDelay.vi" Type="VI" URL="/&lt;vilib&gt;/express/express execution control/TimeDelayBlock.llb/subTimeDelay.vi"/>
				<Item Name="TagReturnType.ctl" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/TagReturnType.ctl"/>
				<Item Name="Three Button Dialog CORE.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Three Button Dialog CORE.vi"/>
				<Item Name="Three Button Dialog.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Three Button Dialog.vi"/>
				<Item Name="Trim Whitespace.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Trim Whitespace.vi"/>
				<Item Name="whitespace.ctl" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/whitespace.ctl"/>
			</Item>
		</Item>
		<Item Name="Build-Spezifikationen" Type="Build"/>
	</Item>
</Project>
