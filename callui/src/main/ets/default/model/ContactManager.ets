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
 * @file: Contact management
 */

import featureAbility from '@ohos.ability.featureAbility';
import dataAbility from '@ohos.data.dataAbility';
import HiLog from '../common/utils/Hilog';

const TAG = "ContactManager";
const DBbaseUri = 'dataability:///com.ohos.contactsdataability';
const DBUri = DBbaseUri + '/contacts/contact_data';

/**
 * class ContactManager
 */
export default class ContactManager {

  /**
   * get contact info
   *
   * @param { Object } callData -Object
   */
   async getContactInfo(callData) {
        try {
            const columns = ['id', 'display_name', 'detail_info'];
            const predicates = new dataAbility.DataAbilityPredicates();
            predicates.equalTo('detail_info', callData.accountNumber);
            const dataAbilityHelper = await featureAbility.acquireDataAbilityHelper(DBbaseUri);
            const resSet = await dataAbilityHelper.query(DBUri, columns, predicates);
            HiLog.i(TAG, "getContactInfo resSet : %s")
            if (resSet.rowCount > 0) {
                resSet.goToFirstRow();
                callData.contactName = resSet.getString(resSet.getColumnIndex('display_name'));
            }
        } catch (err) {
          HiLog.i(TAG, "getContactInfo catch err : %s" + JSON.stringify(err))
        }
    }
}