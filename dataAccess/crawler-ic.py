from tqdm import tqdm
import pandas as pd
import requests
import time

class Crawler:
    def __init__(self):
        self.type_url = "https://searchapi.energylabelrecord.com/record/clist.do"
        self.list_url = "https://searchapi.energylabelrecord.com/record/list.do"
        self.detail_url = "https://searchapi.energylabelrecord.com/record/get.do"
        self.models = {}
        self.result = pd.DataFrame()                                             #用了pd
        self.data = {'pageNum': 1, 'pageSize': 10}                               #data字典类型
        self.types = {'备案号': 'recordNo', '产品型号': 'markingTitle'}

    @staticmethod
    def get(url, data):                                                          #基本的函数，后面经常出现，作用为返回字符串类型的response
        response = requests.get(url, data, timeout=30)
        response.raise_for_status()                                              #requests类的某方法（貌似是检查错误）
        response.encoding = response.apparent_encoding
        return response

    #输入url和data，requests方法获得response

    def __get_total(self):
        response = self.get(self.type_url, {'_': int(time.time())})              #调用上述get函数（传入type的url）赋值给response……get函数后面的data部分字典类型什么意思【？】
        self.models = {_['text']: _['value'] for _ in response.json()}           #给self.models赋值，为response结果的各项

    def __get_products(self):
        return self.get(self.list_url, self.data).json()                         #调用上述get函数（传入list的url），输出结果为十项的json

    def run(self, model, type_, typeValue):                                      #主要函数，model：查询的类型；type_：产品型号；typeValue：具体的型号参数值
        self.__get_total()
        ec_model_no = self.models[model]
        self.data['ec_model_no'] = ec_model_no                                   #输入：要查询的类型
        self.data['type'] = self.types[type_]                                    #输入：'产品型号'→markingTitle
        self.data['typeValue'] = typeValue                                       #输入：具体的产品型号
        self.data['_'] = time.time()
        products = self.__get_products()                                         #得到结果表单并存到products
        for product in tqdm(products):
            response = self.get(self.detail_url, {'uid': product['uid'], '_': int(time.time())}).json()
            params_list = {param['desc'].replace(' ', ''): param['value'].replace(' ', '') for param in response['paramslist']}
            response = dict(response,**params_list)
            self.result = self.result.append(pd.DataFrame().from_dict({0: response}).T, ignore_index=True)
        try:
            self.result.rename(columns={'cname': '类型名称',
                                        'model': '型号',
                                        'recordno': '备案号码',
                                        'level': '级别',
                                        'pubdate': '发布时间',
                                        'recordtype': '备案类型',
                                        'unit': '单位'}, inplace=True)
            self.result.drop(columns=['producer', 'paramslist', 'cid', '依据国家标准'], inplace=True)
            self.result.set_index('uid', inplace=True)
            if model == '家用电磁灶 2008版':
                self.result = self.result[['类型名称','型号','备案号码','级别','发布时间','备案类型','单位','生产者名称','热效率（%）','待机状态功率（W）']]
            elif model == '家用电磁灶 2014版':
                self.result = self.result[['类型名称','型号','备案号码','级别','发布时间','备案类型','单位','生产者名称','热效率（%）','待机状态功率（W）']]
        except Exception as err:
            print(str(err))
            self.result = None


#################
import xlrd
import os

#rawbook = xlrd.open_workbook('/Users/zonghanli/Library/CloudStorage/OneDrive-个人/SEA/202206-本科毕设/data/电储水热水器-线上-13-19.xlsx')
rawbook = xlrd.open_workbook('dcl_am.xlsx')
rawsheet = rawbook.sheet_by_name('Raw')
result_total_1 = pd.DataFrame()

if __name__ == "__main__":
        #headers = list(.columns.values.tolist())
        #f_csv.writerow(headers)
    for i in range(2810, rawsheet.nrows):                #rawsheet.nrows-1
        print ("【———— 进度：%d / %d ————】" %(i, rawsheet.nrows))
        product_row = rawsheet.row_values(i)
        product_name = product_row[1]
        product_label = product_row[0]
        print(product_name)
        '''
        filename1 = 'result家用电磁灶 2008版.csv'
        crawler1 = Crawler()
        crawler1.run('家用电磁灶 2008版', '产品型号', product_name)
        if type(crawler1.result) != type(None):
            result_real = crawler1.result[crawler1.result.型号 == product_name]
            result_real['厂商_源数据'] = product_label
            if os.path.exists(filename1):
                result_real.to_csv(filename1, encoding='gbk', mode='a', header=False, index=False)
            else:
                result_real.to_csv(filename1,encoding='gbk',index=False)
           '''     
        filename2 = 'result家用电磁灶 2014版.csv'
        crawler2 = Crawler()
        crawler2.run('家用电磁灶 2014版', '产品型号', product_name)
        if type(crawler2.result) != type(None):
            result_real = crawler2.result[crawler2.result.型号 == product_name]
            result_real['厂商_源数据'] = product_label
            if os.path.exists(filename2):
                result_real.to_csv(filename2, encoding='gbk', mode='a', header=False, index=False)
            else:
                result_real.to_csv(filename2,encoding='gbk',index=False)

    #result_total_1.to_csv('result2008.csv',encoding='gbk',index=False)
    #result_total_2.to_csv('result2013.csv',encoding='gbk',index=False)
