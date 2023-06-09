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

/**
 * @file: Header information display component
 */

import callList from '../components/CallList';
import Utils from '../utils/utils';
import callStateConst from '../constant/CallStateConst';
import HiLog from '../utils/Hilog';

const TAG = "contactCard";

/**
 * call global variable
 */
let callTimeList;
let defaultTemp = globalThis.exports.default;
if (defaultTemp != undefined) {
  callTimeList = defaultTemp.data.callTimeList;
}

@Component
export default struct ContactCard {
  @State callStateText: string = '';
  @State dialing: string = '.';
  @Prop isShowKeyboard: boolean;
  @Link callList: Array<any>;
  @Link callData: any;
  private mUtils: Utils;
  private timer;
  @StorageLink("CallTimeList") callTimeList: any = [];
  @StorageLink("TextInput") textInput: string = '';
  @StorageLink("TextInputValue") textInputValue: string = '';
  @StorageLink("AccountNumber") accountNumber: string = '';

  public aboutToAppear(callData, callList, callTimeList): void  {
    HiLog.i(TAG, "aboutToAppear");
    this.mUtils = Utils.getInstance();
    this.timer = setInterval(() => {
      if (this.dialing === '...') {
        this.dialing = '';
      }
      this.dialing += '.';
    },500)
    if (this.callData.callState === 3) {
      clearInterval(this.timer)
    }
  }

  /**
   * Call status
   *
   * @return {number} - Call status
   */
  public callState() {
    HiLog.i(TAG, "callState this.callData.callState : %s", this.callData.callState);
    return this.callData.callState;
  }

  /**
   * Whether to display the time
   *
   * @return {boolean} - return success true fail false
   */
  private isShowTime() {
    return this.callState() === callStateConst.CALL_STATUS_ACTIVE && this.callList.length === 1;
  }

  /**
   * Determine whether to display the call list or the input box
   *
   * @return {boolean} - return success true fail false
   */
  private isShowCard() {
    return this.callList.length === 1 || (this.callList.length > 1 && this.callList.some((v) =>
    v.callState === callStateConst.CALL_STATUS_WAITING));
  }

  build() {
    GridContainer({ gutter: 24, margin: 24 }) {
      Column() {
        if (!this.isShowKeyboard) {
          Column() {
            Image($r("app.media.ic_public_avatar"))
              .width(110)
              .height(110)
              .borderRadius(55)
              .margin({ bottom: 18 })
          }
        }

        if (this.isShowKeyboard && this.textInput.length === 0) {
          Column() {
            Text(this.callData.contactName ? this.callData.contactName : this.accountNumber)
              .fontSize(30)
              .height(40)
              .lineHeight(40)
              .fontWeight(FontWeight.Medium)
              .fontColor('#FFFFFF')
              .margin({ bottom: 8, top: 64 })
          }
        } else if (!this.isShowKeyboard) {
          Column() {
            Text(this.callData.contactName ? this.callData.contactName : this.accountNumber)
              .fontSize(30)
              .height(40)
              .lineHeight(40)
              .fontWeight(FontWeight.Medium)
              .fontColor('#FFFFFF')
              .margin({ bottom: 8 })
          }
        } else if (this.isShowKeyboard && this.textInput.length != 0) {
          Scroll() {
            Text(this.textInputValue)
              .height(40)
              .fontSize(30)
              .lineHeight(40)
              .fontWeight(FontWeight.Medium)
              .margin({ bottom: 8, top: 64 })
              .fontColor('#FFFFFF')
              .onTouch((event: TouchEvent) => {
                if (event.type === TouchType.Move) {
                  this.textInputValue = this.textInput
                }
              })
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .width('100%')
        }

        Row() {
          if (!this.isShowKeyboard || this.isShowKeyboard && this.textInput.length === 0) {
            Text(this.callData.contactName ? this.accountNumber : '')
              .fontSize(14)
              .height(19)
              .lineHeight(16)
              .fontColor('#FFFFFF')
              .margin({ bottom: 8 })
              .visibility(this.callData.contactName && !this.isShowKeyboard ? Visibility.Visible : Visibility.None)
          }
        }

        if (this.callData.callState === 2) {
          Row() {
            Text($r("app.string.dialing"))
              .fontSize(14)
              .height(19)
              .lineHeight(16)
              .fontColor('#FFFFFF')
              .align(Alignment.Start)

            Text(this.dialing)
              .fontColor('#FFFFFF')
          }
          .width(60)
        }

        if (this.callData.callState === 3) {
          Column() {
            Text($r("app.string.partyIsRinging"))
              .fontSize(14)
              .height(19)
              .lineHeight(16)
              .fontColor('#FFFFFF')
          }
        }

        if (this.isShowTime()) {
          Column() {
            Text(this.callTimeList[0].callTime)
              .fontSize(14)
              .height(19)
              .lineHeight(19)
              .fontColor('#FFFFFF')
          }
        }
      }
      .useSizeType({
        sm: { span: 4, offset: 0 },
        md: { span: 6, offset: 1 },
        lg: { span: 6, offset: 3 }
      })
    }
  }
}