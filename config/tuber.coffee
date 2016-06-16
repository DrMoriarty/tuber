braintree = require 'braintree'

module.exports.tuber = {
    dpd_prices: [
        {'weight': 3, 'price': 3.34, 'delivery': 1.10}
        {'weight': 5, 'price': 3.62, 'delivery': 1.20}
        {'weight': 10, 'price': 4.01, 'delivery': 1.30}
        {'weight': 15, 'price': 4.42, 'delivery': 1.50}
        {'weight': 20, 'price': 4.77, 'delivery': 1.60}
        {'weight': 25, 'price': 5.35, 'delivery': 1.90}
        {'weight': 31.5, 'price': 6.06, 'delivery': 2.00}
    ]
    braintree: 
        #environment:  braintree.Environment.Production
        #merchantId:   '6y2m8cxqccs373b8'
        #publicKey:    '96dwxqd8tppggct6'
        #privateKey:   '2c38014ddf08d4a2849be745c6e96a41'
        environment: braintree.Environment.Sandbox
        merchantId: 'vs3nz3h3jzk5b42m'
        publicKey: 'kkhysrr54nrv2z3z'
        privateKey: '9e95960119e025f7c1cade114eefb3b4'
    dpd: 
        dpdUserName: '2406008738'
        dpdPassword: 'kxra4'
    mailing: 
        host: 'smtp2.delti.com'
        port: 25
        user: 'svc_packet24'
        pass: 'WaeZaeh4qu'
    paypal: 
        mode: 'live' #sandbox or live
        'client_id': 'Ab-kxGLHnY1TsnXH5gr_9VkDHTY7aLzbPlN6YsOa7IpT_RyVlPYar3EIQGfG2cmZCyu2EQ1HlphNXJHB'
        'client_secret': 'EGHm9UL-A-phWhY9m-EyRgugGq3zt2gDQMIoNMjbZRiy9HmBMk9LwlyMvIAxl4-OsIiwSY1hop_nWxtM'
    defaultAdmin:
        firstname: 'Admin'
        lastname: 'Admin'
        email: 'admin@me.com'
        password: 'admin'
        address1: 'Kremlin sq.'
        address2: 'bt. 1'
        zip: '160000'
        city: 'Vologda'
        country: 'Russia'
        phone: '01'
    driverAcceptTime: 12  #hours
    archiveParcelTime: 4  #hours
}
