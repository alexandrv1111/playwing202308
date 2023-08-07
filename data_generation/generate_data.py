from faker import Faker
from datetime import datetime as dt
from datetime import timedelta as tdelta 
import string
import pandas as pd
import os
import pycountry
import random


countries_of_presence = [Faker().country_code() for _ in range(10)]
countries_of_presence.append('CA')
def generate_articles (n):


    f= Faker()

    article_names = string.ascii_uppercase
    
    articles_countries = []

    for name in article_names:
        desc = f.paragraph()
        for c_code in countries_of_presence:
            articles_countries.append([name, c_code, pycountry.countries.get(alpha_2=c_code).name, desc ])

    unique_indicies = [_+1 for _ in range(len(articles_countries))]
    ids_countries = {
        unique_indicies[_]:articles_countries[_] for _ in range(len(unique_indicies))
    }

    test = []

    for _ in range(n):
        record = {}
        id = random.choice(unique_indicies)
        record['article_id'] = id
        record['name'],\
        record['country_code'],\
        record['country_name'],\
        record['description'] = ids_countries[id]
        record['valid_from'] = f.date_time_between(
            start_date = dt(2015,1,1,0,0,0),
            end_date = dt(2023,6,6,0,0,0) ).strftime("%Y-%m-%d %H:%M:%S")
        record['price'] = round(random.uniform(1, 100), 2)
        record['valid_to'] = dt(9999,12,31,23,59,59).strftime("%Y-%m-%d %H:%M:%S")
        test.append(record)
        
    d = pd.DataFrame(test)

    df = d.sort_values(['name', 'country_code', 'valid_from']).copy().reset_index(drop=True)
    df['key'] = df.index+1
    
    df['valid_from'] = df['valid_from'].astype('object')
    for idx, row in df.iterrows():
        if df.iloc[idx]['article_id'] == df.iloc[idx-1]['article_id']:
            df.at[idx-1,'valid_to'] = df.iloc[idx]['valid_from']

    return df

def generate_clients (n):
    f= Faker()

    ids = [f.unique.pyint(min_value=1, max_value=9999) for _ in range(n)]
    country_codes  = [random.choice(countries_of_presence) for _ in range(n)]
    country_names  = [pycountry.countries.get(alpha_2=cc).name for cc in country_codes]
    cities  = [f.city() for _ in range(n)]
    addresses = [f.unique.address() for _ in range(n)]
    fnames = [f.first_name() for _ in range(n)]
    lnames = [f.last_name() for _ in range(len(fnames))]
    keys = [i+1 for i in range(len(ids))]
    
    data = {}
    data['key'] = keys
    data['client_id'] = ids
    data['country_code'] = country_codes
    data['country_name'] = country_names
    data['city'] = cities
    data['address'] = addresses
    data['fname'] = fnames
    data['lname'] = lnames

    df = pd.DataFrame(data)
    df['key'] = df.index+1

    return df

def generate_transactions(n, clients, articles):
    f= Faker()
    transaction = {}
    transaction['id']               = [_+1 for _ in range(n)]
    transaction['client_id']        = [f.random.choice(clients.client_id) for _ in range(n)]
    transaction['client_key']        = []
    transaction['datetime']         = []
    transaction['article_id']       = []
    transaction['article_key']      = []
    transaction['amount']           = [random.randint(1,5) for _ in range(n) ]

    articles['valid_from']  = articles['valid_from'].astype('object') 
    articles['valid_to']    = articles['valid_to'].astype('object') 

    for i,tid in enumerate(transaction['id']):
        country_of_client = clients.loc[clients['client_id']==transaction['client_id'][i]].country_code.iloc[0]
        articles_in_country = articles.loc[articles['country_code']==country_of_client]
        article_to_buy_key = int(random.choice(articles_in_country.key.to_list()))
        article_id, min_trans_time, max_trans_time = articles_in_country.loc[articles_in_country.key==article_to_buy_key][['article_id', 'valid_from','valid_to']].values[0]

        maxdate, maxtime = max_trans_time.split(' ')
        maxdate_tuple = tuple([int(x) for x in maxdate.split('-')])
        maxtime_tuple = tuple([int(x) for x in maxtime.split(':')])
        max_date_dt  = min(dt(*maxdate_tuple+maxtime_tuple), dt(2023,6,6,0,0,0) )
        
        mindate, mintime = min_trans_time.split(' ')
        mindate_tuple = tuple([int(x) for x in mindate.split('-')])
        mintime_tuple = tuple([int(x) for x in mintime.split(':')])
        min_date_dt  = dt(*mindate_tuple+mintime_tuple)

        tdt = f.date_time_between_dates(
            datetime_start = min_date_dt,
            datetime_end = max_date_dt-tdelta(seconds=1),
            tzinfo=None)

        transaction['datetime'].append(tdt)
        transaction['article_key'].append(article_to_buy_key)
        transaction['article_id'].append(article_id)
        transaction['client_key'] .append(clients.loc[clients['client_id']==transaction['client_id'][i]].key.iloc[0])

    df = pd.DataFrame(transaction)
    return df


def gen_data(n_c, n_a, n_t):
    """
        accept: 
            n_c: number of clients
            n_a: number of articles
            n_t: number of transactions
        return:
            3 DataFrames
    """
    clients = generate_clients(n_c)
    articles = generate_articles(n_a)
    transactions = generate_transactions(n_t, clients=clients, articles=articles)

    outdir = r".\data_generation\GeneratedData"
    if os.path.exists(outdir):
        for existing_file in os.listdir(outdir):
            os.remove(os.path.join(outdir, existing_file))
    else: 
        os.mkdir(outdir)
    
    clients=clients.loc[:, ['key', 'client_id', 'fname', 'lname', 'country_code',	'country_name',	'city',	'address']]
    articles = articles.loc[:, ['key', 'article_id', 'name', 'country_code', 'country_name', 'description', 'price', 'valid_from',	'valid_to']]
    transactions = transactions.loc[:, ['id', 'datetime', 'client_id', 'client_key', 'article_id', 'article_key', 'amount']]
    
    # clients.to_csv('GeneratedData/clients.csv', index=False, header=True, sep='\t')
    # articles.to_csv('GeneratedData/articles.csv', index=False, header=True, sep='\t')
    # transactions.to_csv('GeneratedData/transactions.csv', index=False, header=True, sep='\t')
    clients.to_csv(outdir + r'\clients.csv', index=False, header=True, sep='\t')
    articles.to_csv(outdir + r'\articles.csv', index=False, header=True, sep='\t')
    transactions.to_csv(outdir + r'\transactions.csv', index=False, header=True, sep='\t')

    return clients, articles, transactions




if __name__ == '__main__':
    try:
        gen_data(n_c=100, n_a=100, n_t=10_000)
        print('Data Generated')
    except Exception as e:
        print(e)
        raise(e)

    