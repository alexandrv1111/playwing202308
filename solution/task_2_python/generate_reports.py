import pandas as pd
import os



def generate_report(path_to_excel):
        
    revenue_details_df = pd.read_excel(path_to_excel, sheet_name='revenue_details')
    active_servers_df = pd.read_excel(path_to_excel, sheet_name='active_servers')

    # total revenue by server for last 7 days
    revenue_of_all_servers = revenue_details_df.copy()

    # sum up 7-days income
    revenue_of_all_servers['sum_last_7_d'] = (
        revenue_of_all_servers.sort_values("Date")
        .groupby(['Server'])['Revenue_USD']
        .transform(lambda x: x.rolling(7, min_periods=1).sum()))

    revenue_of_active_servers = revenue_of_all_servers.loc[revenue_of_all_servers.Server.isin(active_servers_df.Server.unique())]

    #  total revenue for all servers for last 7 days
    total_revenue_of_all_servers = revenue_of_all_servers.groupby(['Date'], as_index=False)[['Revenue_USD']].sum()
    total_revenue_of_all_servers['sum_last_7_d'] = total_revenue_of_all_servers.Revenue_USD.transform(lambda x: x.rolling(7, min_periods=1).sum())

    try:
        outdir = r'solution\task_2_python\GeneratedRepots'
        if os.path.exists(outdir):
            for existing_file in os.listdir(outdir):
                os.remove(os.path.join(outdir, existing_file))
        else: 
            os.mkdir(outdir)

        revenue_of_active_servers.to_csv(outdir + r'\revenue_active_servers.csv', index=False, header=True)
        total_revenue_of_all_servers.to_csv(outdir + r'\revenue_all_servers.csv', index=False, header=True)
        print('Reports are Generated')
    except Exception as e:
        print(e)
        raise(e)
    
    

if __name__ == '__main__':
    pw_excel = r"solution\task_2_python\data\Playwing - Python Test Task [BI Engineer].xlsx"
    generate_report(pw_excel)
