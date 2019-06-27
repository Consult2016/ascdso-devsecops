import { step, TestSettings, Until, By, Device } from '@flood/element'
import * as assert from 'assert'

export const settings: TestSettings = {
  clearCache: false,
  disableCache: false,
  clearCookies: false,
  loopCount: 1,
  duration: -1,
  actionDelay: 1.5,
  stepDelay: 3,
  waitTimeout: 60,
  screenshotOnFailure: true,
  DOMSnapshotOnFailure: true
}

/**
 * The Heroku App
 * @version 1.0
 */

export default () => {

	step('Test: 01 - Homepage', async browser => {

		await browser.visit('http://18.208.170.2:7080/')
		await browser.wait(Until.elementIsVisible(By.css('#content > h1')))
		let pageTextVerify = By.visibleText('Welcome to the-internet')
		await browser.wait(Until.elementIsVisible(pageTextVerify))
		//await browser.takeScreenshot()

	})

	step('Test: 02 - AB Testing', async browser => {
	
		let linkHref = await browser.findElement(By.css('#content > ul > li:nth-child(1) > a'))
		await linkHref.click()
		await browser.wait(Until.elementIsVisible(By.css('#content > div > h3')))
		let pageTextVerify = By.visibleText('This is a way')
		await browser.wait(Until.elementIsVisible(pageTextVerify))

	})

	step('Test: 01 - Homepage ', async browser => {

		await browser.visit('http://18.208.170.2:7080/')
		await browser.wait(Until.elementIsVisible(By.css('#content > h1')))
		let pageTextVerify = By.visibleText('Welcome to the-internet')
		await browser.wait(Until.elementIsVisible(pageTextVerify))

	})

	step('Test: 03 - Challenging DOM', async browser => {
	
		let linkHref = await browser.findElement(By.css('#content > ul > li:nth-child(4) > a'))
		await linkHref.click()
		await browser.wait(Until.elementIsVisible(By.css('#content > div')))

	})

	step('Test: 03.1 - Challenging DOM - Click Button', async browser => {
	
		let Button = await browser.findElement(By.xpath("//*[contains(@class, 'button')]"))
		await Button.click()
		let pageTextVerify = By.visibleText('Challenging DOM')
		await browser.wait(Until.elementIsVisible(pageTextVerify))

	})

	step('Test: 03.2 - Challenging DOM - Click Button Alert', async browser => {
	
		let ButtonAlert = await browser.findElement(By.xpath("//*[contains(@class, 'button alert')]"))
		await ButtonAlert.click()
		let pageTextVerify = By.visibleText('Challenging DOM')
		await browser.wait(Until.elementIsVisible(pageTextVerify))

	})

	step('Test: 03.3 - Challenging DOM - Click Button Success', async browser => {

		let ButtonSuccess = await browser.findElement(By.xpath("//*[contains(@class, 'button success')]"))
		await ButtonSuccess.click()
		let pageTextVerify = By.visibleText('Challenging DOM')
		await browser.wait(Until.elementIsVisible(pageTextVerify))

	})

	step('Test: 01 - Homepage  ', async browser => {

		await browser.visit('http://18.208.170.2:7080/')
		await browser.wait(Until.elementIsVisible(By.css('#content > h1')))
		let pageTextVerify = By.visibleText('Welcome to the-internet')
		await browser.wait(Until.elementIsVisible(pageTextVerify))

	})

	step('Test: 04 - Dynamic Content', async browser => {
	
		let linkHref = await browser.findElement(By.css('#content > ul > li:nth-child(10) > a'))
		await linkHref.click()
		await browser.wait(Until.elementIsVisible(By.css('#content > div > h3')))
		let pageTextVerify = By.visibleText('Dynamic Content')
		await browser.wait(Until.elementIsVisible(pageTextVerify))

	})

	step('Test: 04.1 - Dynamic Content - Dynamic Parameter', async browser => {

		let linkDyn = await browser.findElement(By.css('#content > div > p:nth-child(3) > a'))
		await linkDyn.click()
		await browser.wait(Until.elementIsVisible(By.css('#content > div > h3')))

	})

	step('Test: 01 - Homepage   ', async browser => {

		await browser.visit('http://18.208.170.2:7080/')
		await browser.wait(Until.elementIsVisible(By.css('#content > h1')))
		let pageTextVerify = By.visibleText('Welcome to the-internet')
		await browser.wait(Until.elementIsVisible(pageTextVerify))

	})

	step('Test: 05 - Status Codes', async browser => {
	
		let linkHref = await browser.findElement(By.css('#content > ul > li:nth-child(37) > a'))
		await linkHref.click()
		await browser.wait(Until.elementIsVisible(By.css('#content > div > h3')))
		let pageTextVerify = By.visibleText('Status Codes')
		await browser.wait(Until.elementIsVisible(pageTextVerify))

	})

	step('Test: 05.1 - Status Codes - Code 200', async browser => {	

		let link200 = await browser.findElement(By.css('#content > div > ul > li:nth-child(1) > a'))
		await link200.click()
		let pageTextVerify200 = By.visibleText('200')
		await browser.wait(Until.elementIsVisible(pageTextVerify200))
		let linkback = await browser.findElement(By.css('#content > div > p > a'))
		await linkback.click()

	})

	step('Test: 05.2 - Status Codes - Code 301', async browser => {	

		let link301 = await browser.findElement(By.css('#content > div > ul > li:nth-child(2) > a'))
		await link301.click()
		let pageTextVerify301 = By.visibleText('301')
		await browser.wait(Until.elementIsVisible(pageTextVerify301))
		let linkback = await browser.findElement(By.css('#content > div > p > a'))
		await linkback.click()

	})

	step('Test: 05.3 - Status Codes - Code 404', async browser => {	

		let link404 = await browser.findElement(By.css('#content > div > ul > li:nth-child(3) > a'))
		await link404.click()
		let pageTextVerify404 = By.visibleText('404')
		await browser.wait(Until.elementIsVisible(pageTextVerify404))
		let linkback = await browser.findElement(By.css('#content > div > p > a'))
		await linkback.click()

	})

	step('Test: 05.4 - Status Codes - Code 500', async browser => {	

		let link500 = await browser.findElement(By.css('#content > div > ul > li:nth-child(4) > a'))
		await link500.click()
		let pageTextVerify500 = By.visibleText('500')
		await browser.wait(Until.elementIsVisible(pageTextVerify500))
		let linkback = await browser.findElement(By.css('#content > div > p > a'))
		await linkback.click()

	})

}