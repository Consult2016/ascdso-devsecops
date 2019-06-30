import { step, TestSettings, Until, By, Device } from '@flood/element'
import * as assert from 'assert'

export const settings: TestSettings = {
  clearCache: false,
  disableCache: false,
  clearCookies: false,
  loopCount: 1,
  duration: -1,
  actionDelay: 1,
  stepDelay: 2,
  waitTimeout: 60,
  screenshotOnFailure: true,
  DOMSnapshotOnFailure: true
}

/**
 * Saleforce
 * @version 1.0
 * https://raw.githubusercontent.com/daeep/Flood_Element/master/test_classic.ts
 */

const username = "account@flood.io"
const password = "account123"
const account = "Test123"
const contactFN = "Test123"
const contactLN = "Floodio"
const opportunity = "Floodio123"

export default () => {

	step('Test: 01 - Homepage', async browser => {

		await browser.visit('https://login.salesforce.com/')
		await browser.wait(Until.elementIsVisible(By.css('#username')))
		await browser.wait(Until.elementIsVisible(By.css('#password')))
		await browser.wait(Until.elementIsVisible(By.css('#Login')))
		await browser.takeScreenshot()

	})

	step('Test: 02 - Login', async browser => {
	
		await browser.type(By.css('#username'), username)
		await browser.type(By.css('#password'), password)
		let buttonLogin = await browser.findElement(By.css('#Login'))
		await buttonLogin.click()
		await browser.takeScreenshot()

	})

	step('Test: 03 - Home',  { waitTimeout: 90 },async browser => {

		await browser.wait(Until.elementIsVisible(By.id('home_Tab')))
		await browser.takeScreenshot()

	})

	step('Test: 04 - Accounts', async browser => {
	
		let linkAccounts = await browser.findElement(By.id('Account_Tab'))
		await linkAccounts.click()
		await browser.wait(Until.elementIsVisible(By.css('#hotlist > table > tbody > tr > td.pbButton > input')))
		await browser.takeScreenshot()

	})

	step('Test: 05 - New Accounts', async browser => {
	
		let linkNewAccount = await browser.findElement(By.css('#hotlist > table > tbody > tr > td.pbButton > input'))
		await linkNewAccount.click()
		await browser.wait(Until.elementIsVisible(By.css('#bodyCell > div.bPageTitle > div.ptBody > div.content > h2')))
		await browser.takeScreenshot()

	})

	step('Test: 06 - Fill New Accounts', async browser => {

		await browser.type(By.css('#acc2'), account)
		await browser.type(By.css('#acc10'), "9612338892")
		await browser.selectByText(By.css('#acc6'), "Prospect")
		await browser.selectByText(By.css('#acc14'), "Public")
		await browser.selectByText(By.css('#acc7'), "Other")
		await browser.takeScreenshot()

	})

	step('Test: 07 - Save New Accounts', async browser => {

		let linkSaveAccount = await browser.findElement(By.css('#topButtonRow > input:nth-child(1)'))
		await linkSaveAccount.click()
		await browser.wait(Until.elementIsVisible(By.css('#publishersharebutton')))
		await browser.takeScreenshot()

	})

	step('Test: 08 - Contacts', async browser => {
	
		let linkNewContact = await browser.findElement(By.id('Contact_Tab'))
		await linkNewContact.click()
		await browser.wait(Until.elementIsVisible(By.css('#hotlist > table > tbody > tr > td.pbButton > input')))
		await browser.takeScreenshot()

	})

	step('Test: 09 - New Contact', async browser => {
	
		let linkNewContact = await browser.findElement(By.css('#hotlist > table > tbody > tr > td.pbButton > input'))
		await linkNewContact.click()
		await browser.wait(Until.elementIsVisible(By.css('#name_firstcon2')))
		await browser.takeScreenshot()

	})

	step('Test: 10 - Fill New Contact', async browser => {

		await browser.type(By.css('#name_firstcon2'), contactFN)
		await browser.type(By.css('#name_lastcon2'), contactLN)
		await browser.type(By.css('#con10'), "9612338892")
		await browser.selectByText(By.css('#con9'), "Web")
		await browser.type(By.css('#con19city'), "Mexico")
		await browser.type(By.css('#con19zip'), "29090")
		await browser.takeScreenshot()

	})

	step('Test: 11 - Save New Contact', async browser => {

		let linkSaveContact = await browser.findElement(By.css('#topButtonRow > input:nth-child(1)'))
		await linkSaveContact.click()
		await browser.wait(Until.elementIsVisible(By.css('#publishersharebutton')))
		await browser.takeScreenshot()

	})

	step('Test: 12 - Opportunity', async browser => {
	
		let linkNewContact = await browser.findElement(By.id('Opportunity_Tab'))
		await linkNewContact.click()
		await browser.wait(Until.elementIsVisible(By.css('#hotlist > table > tbody > tr > td.pbButton > input')))
		await browser.takeScreenshot()

	})

	step('Test: 13 - New Opportunity', async browser => {
	
		let linkNewOpp = await browser.findElement(By.css('#hotlist > table > tbody > tr > td.pbButton > input'))
		await linkNewOpp.click()
		await browser.wait(Until.elementIsVisible(By.css('#opp3')))
		await browser.takeScreenshot()

	})

	step('Test: 14 - Fill New Opportunity', async browser => {

		await browser.type(By.css('#opp3'), opportunity)
		let linkPickDate = await browser.findElement(By.css('#ep > div.pbBody > div:nth-child(3) > table > tbody > tr:nth-child(2) > td:nth-child(4) > div > span > span > a'))
		await linkPickDate.click()
		await browser.selectByText(By.css('#opp11'), "Prospecting")
		await browser.selectByText(By.css('#opp5'), "New Customer")
		await browser.selectByText(By.css('#opp6'), "Web")

	})

	step('Test: 15 - Save New Opportunity', async browser => {

		let linkSaveOpp = await browser.findElement(By.css('#bottomButtonRow > input:nth-child(1)'))
		await linkSaveOpp.click()
		await browser.wait(Until.elementIsVisible(By.css('#publishersharebutton')))
		await browser.takeScreenshot()

	})

	step('Test: 16 - Logout', async browser => {
	
		let linkAccount = await browser.findElement(By.css('#userNavButton'))
		await linkAccount.click()
		await browser.wait(Until.elementIsVisible(By.css('#userNav-menuItems > a:nth-child(5)')))
		let linkLogout = await browser.findElement(By.css('#userNav-menuItems > a:nth-child(5)'))
		await linkLogout.click()
		await browser.wait(Until.elementIsVisible(By.css('#signup')))
		await browser.takeScreenshot()

	})

}