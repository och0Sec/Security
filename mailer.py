#!/usr/bin/env python3

import smtplib, ssl

def send_email(subject, body):
    title = "Subject: " + subject + " \n\n"
    message = title + body
    smtp_server = "smtp_server"
    port = 25  # For starttls
    sender_email = "noreply@yourdomain.com"
    password = "your password"
 #Not recomended to store in plaintext
    receiver_email = "email@yourdomain.com"
    
    # Create a secure SSL context
    context = ssl.create_default_context()

    # Try to log in to server and send email
    try:
        server = smtplib.SMTP(smtp_server,port)
        server.ehlo() # Can be omitted
        server.starttls(context=context) # Secure the connection
        server.ehlo() # Can be omitted
        server.login(sender_email, password)
        # TODO: Send email here
        server.sendmail(sender_email, receiver_email, message)
        print("email sent:" + "\n" + message)
    except Exception as e:
        # Print any error messages to stdout
        print(e)
    finally:
        server.quit()
