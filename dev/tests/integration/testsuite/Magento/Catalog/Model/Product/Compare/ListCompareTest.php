<?php
/**
 * Copyright © 2015 Magento. All rights reserved.
 * See COPYING.txt for license details.
 */

namespace Magento\Catalog\Model\Product\Compare;

/**
 * @magentoDataFixture Magento/Catalog/_files/product_simple.php
 * @magentoDataFixture Magento/Customer/_files/customer.php
 */
class ListCompareTest extends \PHPUnit_Framework_TestCase
{
    /**
     * @var \Magento\Catalog\Model\Product\Compare\ListCompare
     */
    protected $_model;

    /**
     * @var \Magento\Customer\Model\Visitor
     */
    protected $_visitor;

    /** @var \Magento\Customer\Model\Session */
    protected $_session;

    protected function setUp()
    {
        /** @var $session \Magento\Customer\Model\Session */
        $this->_session = \Magento\TestFramework\Helper\Bootstrap::getObjectManager()
            ->get('Magento\Customer\Model\Session');
        $this->_visitor = \Magento\TestFramework\Helper\Bootstrap::getObjectManager()
            ->create('Magento\Customer\Model\Visitor');
        /** @var \Magento\Framework\Stdlib\DateTime $dateTime */
        $dateTime = \Magento\TestFramework\Helper\Bootstrap::getObjectManager()
            ->create('Magento\Framework\Stdlib\DateTime');
        $this->_visitor->setSessionId(md5(time()) . md5(microtime()))
            ->setLastVisitAt($dateTime->now())
            ->save();
        $this->_model = \Magento\TestFramework\Helper\Bootstrap::getObjectManager()
            ->create('Magento\Catalog\Model\Product\Compare\ListCompare', ['customerVisitor' => $this->_visitor]);
    }

    protected function tearDown()
    {
        $this->_session->setCustomerId(null);
    }

    public function testAddProductWithSession()
    {
        $this->_session->setCustomerId(1);
        /** @var $product \Magento\Catalog\Model\Product */
        $product = \Magento\TestFramework\Helper\Bootstrap::getObjectManager()
            ->create('Magento\Catalog\Model\Product')
            ->load(1);
        $this->_model->addProduct($product);
        $this->assertTrue($this->_model->hasItems(1, $this->_visitor->getId()));
    }

    public function testAddProductWithoutSession()
    {
        /** @var $product \Magento\Catalog\Model\Product */
        $product = \Magento\TestFramework\Helper\Bootstrap::getObjectManager()
            ->create('Magento\Catalog\Model\Product')
            ->load(1);
        $this->_model->addProduct($product);
        $this->assertFalse($this->_model->hasItems(1, $this->_visitor->getId()));
        $this->assertTrue($this->_model->hasItems(0, $this->_visitor->getId()));
    }
}
