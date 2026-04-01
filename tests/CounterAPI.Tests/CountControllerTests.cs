using Moq;
using Microsoft.AspNetCore.Mvc;

namespace CounterAPI.Tests
{
    [TestClass]
    public class CountControllerTests
    {
        [TestMethod]
        public void IncrementAndGet_ShouldReturnIncrementedValue()
        {
            // Arrange
            var service = new CounterService();

            // Act
            var result = service.IncrementAndGet();

            // Assert
            Assert.AreEqual(1, result);
        }

        [TestMethod]
        public void IncrementAndGet_MultipleCalls_ShouldReturnSequentialIncrementedValues()
        {
            // Arrange
            var service = new CounterService();

            // Act
            var first = service.IncrementAndGet();
            var second = service.IncrementAndGet();
            var third = service.IncrementAndGet();

            // Assert
            Assert.AreEqual(1, first);
            Assert.AreEqual(2, second);
            Assert.AreEqual(3, third);
        }
    }
}