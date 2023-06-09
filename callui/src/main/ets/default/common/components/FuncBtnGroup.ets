/**
 * Copyright (c) 2022 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import  Method from '../utils/Method';
import FuncBtn from './FuncBtn';
import FA from '@ohos.ability.featureAbility';
import CallStateConst from '../constant/CallStateConst';
import CallServiceProxy from '../../model/CallServiceProxy';
import Clone from '../utils/clone';
import ConferenceConst from '../constant/ConferenceConst';
import BtnGroupConfig from '../configs/BtnGroupConfig';
import HiLog from '../utils/Hilog';

const TAG = 'FuncBtnGroup';
const textMap =
  {
    'record': $r('app.string.recording'),
    'keep': $r('app.string.keep'),
    'add': $r('app.string.addCall'),
    'video': $r('app.string.videoCall'),
    'mute': $r('app.string.mute'),
    'contact': $r('app.string.contactPerson'),
    'exchange': $r('app.string.exchange'),
    'merge': $r('app.string.mergeCall'),
  };

@Component
export default struct FuncBtnGroup {
  @Link @Watch ('updateBtnList') callData: any;
  @Link callList: Array<any>;
  @State count: number = 0;
  @State btnList: Array<any> = [];
  @State m: number = 0;
  @State n: number = 0;
  @State oldCallState: any = CallStateConst.CALL_STATUS_IDLE;

  private mCallServiceProxy: CallServiceProxy;
  private mBtnGroupConfig  = BtnGroupConfig;
  private timer: any = null;
  private mClone: Clone;
  private btnListCall;
  private btnListDialing;

  private aboutToAppear(): void  {
    this.mClone = Clone.getInstance()
    this.mCallServiceProxy = CallServiceProxy.getInstance();
    this.mBtnGroupConfig.btnGroupList.forEach((v) => {
      v.iconText = textMap[v.type];
    });
    this.mBtnGroupConfig.threePartyList.forEach((v) => {
      v.iconText = textMap[v.type];
    });
    this.btnListCall = this.mClone.clone(this.mBtnGroupConfig.btnGroupList);
    this.getBtnListCall()
    this.btnList = this.btnListCall
    this.updateBtnList()
    HiLog.i(TAG, "aboutToAppear : ");
  }

  /**
   * Switching BtnList Based on CallStatus
   */
  updateBtnList() {
    if (this.callData.callState === CallStateConst.CALL_STATUS_DIALING|| this.callData.callState === CallStateConst.CALL_STATUS_ALERTING) {
      this.btnList = this.btnListDialing
    }else{
      this.btnList = this.btnListCall
    }
    HiLog.i(TAG, "upData BtnList : %s");
  }

  /**
   * Get BtnList Based on CallStatus
   */
  getBtnListCall() {
    this.btnListDialing = this.mClone.clone(this.mBtnGroupConfig.btnGroupList);
    this.btnListDialing[1].isDisable = true
    this.btnListDialing[2].isDisable = true
    HiLog.i(TAG, "get btnListCall : %s");
  }

  /**
   * update state of group buttons
   *
   * @param {Object} callData - call data
   */
  onCallStateChange(newVal) {
    HiLog.i(TAG, "Calling status changed : %s");
    const BtnName= ['video', 'record', 'add', 'mute', 'contact']
    if (this.callList.length >= 2 && this.callList.every((v) =>
    v.conferenceState !== ConferenceConst.TEL_CONFERENCE_ACTIVE)) {
      this.btnList.splice(1, 2, ...this.mClone.clone(BtnGroupConfig.threePartyList));
    } else {
      this.btnList.splice(1, 2, new Array(BtnGroupConfig.btnGroupList).splice(1, 2));
      this.btnList.splice(1, 2, ...this.mClone.clone(BtnGroupConfig.btnGroupList).splice(1, 2));
    }
    if (newVal === CallStateConst.CALL_STATUS_ACTIVE || newVal === CallStateConst.CALL_STATUS_HOLDING) {
      this.btnList.forEach((item) => {
        if (!Method.includes(BtnName,(item.type))) {
          item.isDisable = false;
        }
      });
      if (newVal === CallStateConst.CALL_STATUS_HOLDING) {
        this.btnList[1].isActive = true;
        this.btnList[4].isDisable = true;
      }
    } else {
      this.btnList.forEach((item) => {
        if (item.type === 'contact') {
          item.isDisable = true;
        }
      });
    }
  }

  /**
   * Display the buttons of the button group
   *
   * @param {Object} obj - object
   */
  btnClick(obj) {
    HiLog.i(TAG, "btnClick get icon type : %s");
    const BtnName= ['record', 'keep', 'video', 'mute']
    const type = obj.type;
    const { callId } = this.callData;
    if (Method.includes(BtnName,type)) {
      this.btnList.forEach((item) => {
        if (item.type === type) {
          item.isActive = !item.isActive;
        }
      });
      if (type === 'record') {
        if (this.btnList[0].isActive) {
        } else {
          this.count = 0;
          clearInterval(this.timer);
          this.btnList[0].iconText = $r('app.string.recording');
        }
      }
    }

    switch (type) {
      case 'record':
        break;
      case 'keep':
        this.keepHandle('keep');
        break;
      case 'exchange':
        this.mCallServiceProxy.switchCall(callId);
        break;
      case 'add':
        FA.startAbility({
          want: {
            bundleName: 'com.ohos.contacts',
            abilityName: 'com.ohos.contacts.MainAbility',
            parameters: {
              pageFlag : 'page_flag_dialer'
            }
          }
        });
        break;
      case 'video':
        break;
      case 'mute':
        this.muteHandle('mute');
        break;
      case 'contact':
        FA.startAbility({
          want: {
            bundleName: 'com.ohos.contacts',
            abilityName: 'com.ohos.contacts.MainAbility',
            parameters: {
              pageFlag: "page_flag_choose_contacts"
            }
          }
        });
        break;
      case 'merge':
        this.mCallServiceProxy.combineConference(callId);
        break;
      default:
        break;
    }
  }

  /**
   * Call hold interface
   *
   * @param {string} type - Click the hold button
   */
  keepHandle(type) {
    const awaitIsActive = this.btnList.find((v) => v.type === type).isActive;
    HiLog.i(TAG, "keep handle %s");
    awaitIsActive ? this.mCallServiceProxy.holdCall(this.callData.callId) : this.mCallServiceProxy.unHoldCall(this.callData.callId);
  }

  /**
   * Call hold mute
   *
   * @param {string} type - Click the hold button
   */
  muteHandle(type) {
    const awaitIsActive = this.btnList.find((v) => v.type === type).isActive;
    HiLog.i(TAG, "mute Handle %s");
    awaitIsActive ? this.mCallServiceProxy.setMuted() : this.mCallServiceProxy.cancelMuted();
  }

  /**
   * Clear timer
   */
  onDestroy() {
    HiLog.i(TAG, "onDestroy %s");
    this.timer && clearInterval(this.timer);
  }

  build() {
    GridContainer({ gutter: 24, margin: 24 }) {
      Row() {
        Grid() {
          ForEach(this.btnList, (item) => {
            GridItem() {
                FuncBtn({
                  btnType: item.type,
                  isDisable: item.isDisable,
                  isActive: item.isActive,
                  iconText: item.iconText,
                  iconDisableUrl: item.iconDisableUrl,
                  iconDefaultUrl: item.iconDefaultUrl,
                  iconActiveUrl: item.iconActiveUrl,
                  btnClick: () => {
                    this.btnClick(item)
                  }
                })
            }
            .height(51.5)
          })
        }
        .columnsGap(24)
        .rowsGap(29.5)
        .height(132.5)
        .columnsTemplate('1fr 1fr 1fr')
        .rowsTemplate('1fr 1fr')
      }
      .useSizeType({
        sm: { span: 4, offset: 0 },
        md: { span: 6, offset: 1 },
        lg: { span: 6, offset: 3 }
      })
    }
  }
}